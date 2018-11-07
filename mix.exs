defmodule Liquor.MixProject do
  use Mix.Project

  def project do
    [
      app: :liquor,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.0", optional: true},
      {:postgrex, ">= 0.14.0", only: [:test]},
      {:ex_machina, ">= 2.2.2", only: [:test]},
    ]
  end
end
