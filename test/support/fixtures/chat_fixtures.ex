defmodule Shat.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shat.Chat` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(_attrs \\ %{}) do
    {:ok, room} =
      Shat.Chat.create_room()

    room
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        content: "some content"
      })
      |> Shat.Chat.create_message()

    message
  end
end
