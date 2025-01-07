defmodule ShatWeb.UserController do
  use ShatWeb, :controller

  alias Shat.Users
  alias Shat.Users.User

  def new(conn, %{"room_name" => room_name}) do
    changeset = Users.change_user(%User{})

    conn
    |> assign(:page_title, "Definir nome de usuário")
    |> render(:new, changeset: changeset, room_name: room_name)
  end

  def create(conn, %{"room_name" => room_name, "user_name" => user_name}) do
    case Users.create_user(%{name: user_name}) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> redirect(to: "/chat/#{room_name}")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Erro ao definir nome.")
        |> render(:new, changeset: changeset, room_name: room_name)
    end
  end
end
