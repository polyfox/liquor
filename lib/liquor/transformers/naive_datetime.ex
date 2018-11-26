defmodule Liquor.Transformers.NaiveDateTime do
  def transform(nil), do: {:ok, nil}
  def transform(""), do: {:ok, nil}

  for s <- [:year, :month, :day, :hour, :minute, :second, :microsecond] do
    prefix = "#{s}:"
    def transform(unquote(prefix) <> value) do
      {:ok, {unquote(s), String.to_integer(value)}}
    end
  end

  def transform(string) when is_binary(string), do: Ecto.Type.cast(:naive_datetime_usec, string)
  def transform(%DateTime{} = dt), do: Ecto.Type.cast(:naive_datetime_usec, dt)
  def transform(%NaiveDateTime{} = dt), do: Ecto.Type.cast(:naive_datetime_usec, dt)
end
