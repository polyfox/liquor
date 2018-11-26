defmodule Liquor.Transformers.Boolean do
  def transform(nil), do: {:ok, nil}
  def transform(""), do: {:ok, nil}
  def transform(bool) when is_boolean(bool), do: {:ok, bool}
  def transform(str) do
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
