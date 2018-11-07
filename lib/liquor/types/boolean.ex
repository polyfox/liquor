defmodule Liquor.Types.Boolean do
  def cast(nil), do: :error
  def cast(bool) when is_boolean(bool), do: {:ok, bool}
  def cast(str) do
    str
    |> String.downcase()
    |> String.trim()
    |> case  do
      t when t in ~w[t true y yes 1] -> {:ok, true}
      f when f in ~w[f false n no 0] -> {:ok, false}
      _ -> :error
    end
  end
end
