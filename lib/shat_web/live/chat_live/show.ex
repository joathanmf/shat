defmodule ShatWeb.ChatLive.Show do
  use ShatWeb, :live_view
  alias Shat.{Chat, Users, Repo}

  def mount(%{"room_name" => room_name}, session, socket) do
    session = Map.merge(session, %{teste: "teste"})

    room = Chat.get_room_by_name(room_name)
    messages = Chat.last_messages(room.id)

    user_id = Map.get(session, "user_id")

    case user_id do
      nil ->
        {:ok, push_navigate(socket, to: "/chat/#{room_name}/set_name")}

      _ ->
        case Users.get_user(user_id) do
          nil ->
            {:ok, push_navigate(socket, to: "/chat/#{room_name}/set_name")}

          user ->
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
