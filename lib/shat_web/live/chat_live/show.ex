defmodule ShatWeb.ChatLive.Show do
  use ShatWeb, :live_view
  alias Shat.{Chat, Users}

  def mount(%{"room_name" => room_name}, session, socket) do
    room = Chat.get_room_by_name!(room_name)

    user_id = Map.get(session, "user_id")

    case user_id do
      nil ->
        {:ok, push_navigate(socket, to: "/chat/#{room_name}/set_name")}

      _ ->
        case Users.get_user!(user_id) do
          nil ->
            {:ok, push_navigate(socket, to: "/chat/#{room_name}/set_name")}

          user ->
            socket =
              socket
              |> assign(room: room, user: user, messages: Chat.last_ten_messages_for(room.id))
              |> stream(:messages, Chat.last_ten_messages_for(room.id))

            if connected?(socket) do
              ShatWeb.Endpoint.subscribe("room_#{room.name}")
            end

            {:ok, socket}
        end
    end
  end

  def handle_event("send_message", %{"content" => content}, socket) do
    if content |> String.trim() != "" do
      message = %{
        content: content,
        user_id: socket.assigns.user.id,
        room_id: socket.assigns.room.id
      }

      {:ok, new_message} = Chat.create_message(message)

      ShatWeb.Endpoint.broadcast("room_#{socket.assigns.room.name}", "new_message", %{
        message: new_message
      })

      {:noreply, stream_insert(socket, :messages, new_message)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{event: "new_message", payload: %{message: message}}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
  end
end
