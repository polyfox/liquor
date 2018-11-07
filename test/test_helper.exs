{:ok, _} = Application.ensure_all_started(:ex_machina)
{:ok, _} = Application.ensure_all_started(:telemetry)

Liquor.Support.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Liquor.Support.Repo, :manual)

ExUnit.start()
