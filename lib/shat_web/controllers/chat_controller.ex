defmodule ShatWeb.ChatController do
  use ShatWeb, :controller

  def set_user(conn, %{"user_id" => user_id, "room_name" => room_name}) do
    conn
    |> put_session(:user_id, user_id)
    |> redirect(to: "/chat/#{room_name}")
  end
end
