defmodule Liquor.Support.Repo do
  use Ecto.Repo,
    otp_app: :liquor,
    adapter: Ecto.Adapters.Postgres
end
