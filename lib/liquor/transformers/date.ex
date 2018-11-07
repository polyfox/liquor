defmodule Liquor.Transformers.Date do
  def transform("year:" <> year) do
    {:ok, {:year, String.to_integer(year)}}
  end

  def transform("month:" <> month) do
    {:ok, {:month, String.to_integer(month)}}
  end

  def transform("day:" <> day) do
    {:ok, {:day, String.to_integer(day)}}
  end

  def transform(string) do
    Ecto.Type.cast(:date, string)
  end
end
