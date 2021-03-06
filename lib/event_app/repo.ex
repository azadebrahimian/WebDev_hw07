defmodule EventApp.Repo do
  use Ecto.Repo,
    otp_app: :event_app,
    adapter: Ecto.Adapters.Postgres
end
