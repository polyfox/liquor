defmodule Liquor.Transformers.DateTime do
  for s <- [:year, :month, :day, :hour, :minute, :second, :millisecond] do
    prefix = "#{s}:"
    def transform(unquote(prefix) <> value) do
      {:ok, {unquote(s), String.to_integer(value)}}
    end
  end

  def transform(string) do
    Ecto.Type.cast(:datetime, string)
  end
end
