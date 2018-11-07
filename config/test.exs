use Mix.Config

config :logger, level: :info

config :liquor, Liquor.Support.Repo, [
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "liquor_test",
  hostname: "localhost",
  username: "postgres"
]

config :liquor, ecto_repos: [Liquor.Support.Repo]
