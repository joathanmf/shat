defmodule Shat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    belongs_to :room, Shat.Chat.Room
    belongs_to :user, Shat.Users.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :room_id, :user_id])
    |> validate_required([:content, :room_id, :user_id])
    |> validate_length(:content, min: 1, max: 1024)
  end
end
