defmodule Liquor.Transformers.NaiveDateTime do
  for s <- [:year, :month, :day, :hour, :minute, :second, :millisecond] do
    prefix = "#{s}:"
    def transform(unquote(prefix) <> value) do
      {:ok, {unquote(s), String.to_integer(value)}}
    end
  end

  def transform(string) do
    Ecto.Type.cast(:naive_datetime_usec, string)
  end
end
