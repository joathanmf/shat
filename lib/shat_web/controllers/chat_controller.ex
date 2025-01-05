defmodule ShatWeb.ChatController do
  use ShatWeb, :controller
  alias Shat.Users

  def set_user(conn, %{"user_name" => user_name, "room_name" => room_name}) do
    # Cria o usuário
    case Users.create_user(%{name: user_name}) do
      {:ok, user} ->
        # Salva o user_id na sessão
        conn
        |> put_session(:user_id, user.id)
        # Redireciona para a sala
        |> redirect(to: "/chat/#{room_name}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Erro ao entrar na sala.")
        |> redirect(to: "/")
    end
  end
end
