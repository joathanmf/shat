defmodule ShatWeb.ChatLive.Show do
  use ShatWeb, :live_view
  alias Shat.{Chat, Users, Repo}

  def mount(%{"room_name" => room_name}, session, socket) do
    case Chat.get_room_by_name(room_name) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Código de chat inválido.")
         |> push_navigate(to: "/")}

      room ->
        case Map.get(session, "user_id") do
          nil ->
            {:ok, push_navigate(socket, to: "/chat/#{room_name}/user/new")}

          user_id ->
            case Users.get_user(user_id) do
              nil ->
                {:ok, push_navigate(socket, to: "/chat/#{room_name}/user/new")}

              user ->
                messages =
                  Chat.last_messages(room.id)
                  |> Enum.map(&%{&1 | inserted_at: Time.to_iso8601(&1.inserted_at)})

                socket =
                  socket
                  |> assign(room: room, user: user)
                  |> stream(:messages, messages)

                if connected?(socket) do
                  ShatWeb.Endpoint.subscribe("room_#{room.name}")
                end

                {:ok, socket}
            end
        end
    end
  end

  def handle_event("send_message", %{"content" => content}, socket) do
    if content |> String.trim() != "" do
      message_params = %{
        content: content,
        user_id: socket.assigns.user.id,
        room_id: socket.assigns.room.id
      }

      case Chat.create_message(message_params) do
        {:ok, new_message} ->
          new_message = Repo.preload(new_message, :user)

          ShatWeb.Endpoint.broadcast("room_#{socket.assigns.room.name}", "new_message", %{
            message: %{
              id: new_message.id,
              content: new_message.content,
              inserted_at: Time.to_iso8601(new_message.inserted_at),
              user: %{
                id: new_message.user.id,
                name: new_message.user.name
              }
            }
          })

          {:noreply, stream_insert(socket, :messages, new_message)}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Erro ao enviar a mensagem.")}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{event: "new_message", payload: %{message: message}}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
  end
end
