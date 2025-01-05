defmodule ShatWeb.ChatLive.Index do
  use ShatWeb, :live_view

  alias Shat.Chat

  def mount(_params, _session, socket) do
    {:ok, assign(socket, error: nil)}
  end

  def handle_event("create_room", _params, socket) do
    case Chat.create_room() do
      {:ok, room} ->
        {:noreply, push_navigate(socket, to: "/chat/#{room.name}")}

      {:error, _changeset} ->
        {:noreply, assign(socket, error: "Erro ao criar a sala.")}
    end
  end

  def handle_event("enter_room", %{"room_name" => room_name}, socket) do
    {:noreply, push_navigate(socket, to: "/chat/#{room_name}")}
  end
end
