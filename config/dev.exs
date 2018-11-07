use Mix.Config

config :liquor, Liquor.Support.Repo, [
  database: "liquor_dev",
  hostname: "localhost",
  username: "postgres"
]

config :liquor, ecto_repos: [Liquor.Support.Repo]
