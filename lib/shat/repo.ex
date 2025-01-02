defmodule Shat.Repo do
  use Ecto.Repo,
    otp_app: :shat,
    adapter: Ecto.Adapters.Postgres
end
