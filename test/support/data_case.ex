defmodule Liquor.Support.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Liquor.Support.Repo
      import Ecto.Query
      import Liquor.Support.DataCase
      import Liquor.Support.Factory
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Liquor.Support.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Liquor.Support.Repo, {:shared, self()})
    end

    {:ok, tags}
  end
end
