defmodule Liquor.Transformers.Date do
  def transform(nil), do: {:ok, nil}
  def transform(""), do: {:ok, nil}

  def transform("year:" <> year) do
    {:ok, {:year, String.to_integer(year)}}
  end

  def transform("month:" <> month) do
    {:ok, {:month, String.to_integer(month)}}
  end

  def transform("day:" <> day) do
    {:ok, {:day, String.to_integer(day)}}
  end

  def transform(string) when is_binary(string), do: Ecto.Type.cast(:date, string)
  def transform(%Date{} = date), do: {:ok, date}
  def transform(%DateTime{} = dt), do: Ecto.Type.cast(:date, dt)
  def transform(%NaiveDateTime{} = dt), do: Ecto.Type.cast(:date, dt)
end
