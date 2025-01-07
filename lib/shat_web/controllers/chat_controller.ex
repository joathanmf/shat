defmodule ShatWeb.ChatController do
  use ShatWeb, :controller

  alias Shat.{Chat, Users}
  alias Shat.Chat.Room

  def index(conn, _params) do
    changeset = Chat.change_room(%Room{})

    conn
    |> assign(:page_title, "Início")
    |> render(:index, changeset: changeset)
  end

  def create(conn, _params) do
    case Chat.create_room() do
      {:ok, room} ->
        redirect_user_to(conn, room.name)

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Erro ao criar chat.")
        |> redirect(to: "/")
    end
  end

  def enter(conn, %{"room_name" => room_name}) do
    case Chat.get_room_by_name(room_name) do
      nil ->
        conn
        |> put_flash(:error, "Código de chat inválido.")
        |> redirect(to: "/")

      room ->
        redirect_user_to(conn, room.name)
    end
  end

  defp fetch_user_from_session(conn) do
    case get_session(conn, :user_id) do
      nil -> nil
      user_id -> Users.get_user(user_id)
    end
  end

  defp redirect_user_to(conn, room_name) do
    case fetch_user_from_session(conn) do
      nil ->
        redirect(conn, to: "/chat/#{room_name}/user/new")

      _user ->
        redirect(conn, to: "/chat/#{room_name}")
    end
  end
end
