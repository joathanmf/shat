defmodule ShatWeb.ChatLive.SetName do
  use ShatWeb, :live_view

  alias Shat.Users

  def mount(%{"room_name" => room_name}, _session, socket) do
    {:ok, assign(socket, room_name: room_name, error: nil)}
  end

  def handle_event("set_name", %{"user_name" => user_name}, socket) do
    case Users.create_user(%{name: user_name}) do
      {:ok, user} ->
        {:noreply,
         push_navigate(
           socket,
           to: "/set_user?user_id=#{user.id}&room_name=#{socket.assigns.room_name}"
         )}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Erro ao criar usuário")
         |> push_navigate(to: "/chat/#{socket.assigns.room_name}/set_name")}
    end
  end
end
