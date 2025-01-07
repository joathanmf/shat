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
        render(conn, :set_user, room: room)

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Erro ao criar chat.")
        |> redirect(to: "/")
    end
  end

  # def set_user(conn, params) do
  #   conn
  #   |> put_session(:user_id, user_id)
  #   |> redirect(to: "/chat/#{room_name}")
  # end

  defp user_in_session(conn) do
    user_id = get_session(conn, :user_id)

    case user_id do
      nil ->
        false

      _ ->
        case Users.get_user(user_id) do
          nil ->
            false

          _user ->
            true
        end
    end
  end
end
