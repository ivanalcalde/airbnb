defmodule Airbnb.Repo do
  use Ecto.Repo,
    otp_app: :airbnb,
    adapter: Ecto.Adapters.Postgres
end
