defmodule ShatWeb.ChatLive.SetName do
  use ShatWeb, :live_view

  def mount(%{"room_name" => room_name}, _session, socket) do
    {:ok, assign(socket, room_name: room_name, error: nil)}
  end

  def handle_event("set_name", %{"user_name" => user_name}, socket) do
    # Em vez de criar o usuário diretamente aqui, chamamos o controlador para salvar na sessão
    {:noreply,
     push_navigate(
       socket,
       to: "/set_user?user_name=#{user_name}&room_name=#{socket.assigns.room_name}"
     )}
  end
end
