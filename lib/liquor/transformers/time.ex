defmodule Liquor.Transformers.Time do
  for s <- [:hour, :minute, :second, :millisecond] do
    prefix = "#{s}:"
    def transform(unquote(prefix) <> value) do
      {:ok, {unquote(s), String.to_integer(value)}}
    end
  end

  def transform(string) do
    Ecto.Type.cast(:time, string)
  end
end
