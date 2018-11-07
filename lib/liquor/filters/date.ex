defmodule Liquor.Filters.Date do
  @moduledoc """
  Specialized module for filtering date fields
  """
  import Ecto.Query

  def apply_filter(query, :match, key, %Date{} = date), do: apply_filter(query, :==, key, date)
  def apply_filter(query, :match, key, {:year, _year} = value), do: apply_filter(query, :==, key, value)
  def apply_filter(query, :match, key, {:month, _month} = value), do: apply_filter(query, :==, key, value)
  def apply_filter(query, :match, key, {:day, _day} = value), do: apply_filter(query, :==, key, value)
  def apply_filter(query, :match, key, {:ym, _year, _month} = value), do: apply_filter(query, :==, key, value)

  def apply_filter(query, :unmatch, key, %Date{} = date), do: apply_filter(query, :!=, key, date)
  def apply_filter(query, :unmatch, key, {:year, _year} = value), do: apply_filter(query, :!=, key, value)
  def apply_filter(query, :unmatch, key, {:month, _month} = value), do: apply_filter(query, :!=, key, value)
  def apply_filter(query, :unmatch, key, {:day, _day} = value), do: apply_filter(query, :!=, key, value)
  def apply_filter(query, :unmatch, key, {:ym, _year, _month} = value), do: apply_filter(query, :!=, key, value)

  @allowed_fields [:year, :month, :day]

  def apply_filter(query, :==, key, %Date{} = date), do: where(query, [r], field(r, ^key) == ^date)
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :==, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) == ^value)
    end
  end

  def apply_filter(query, :!=, key, %Date{} = date), do: where(query, [r], field(r, ^key) != ^date)
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :!=, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) != ^value)
    end
  end

  def apply_filter(query, :>=, key, %Date{} = date), do: where(query, [r], field(r, ^key) >= ^date)
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :>=, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) >= ^value)
    end
  end

  def apply_filter(query, :<=, key, %Date{} = date) do
    where(query, [r], field(r, ^key) <= ^date)
  end
    for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :<=, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) <= ^value)
    end
  end

  def apply_filter(query, :>, key, %Date{} = date) do
    where(query, [r], field(r, ^key) > ^date)
  end
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :>, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) > ^value)
    end
  end

  def apply_filter(query, :<, key, %Date{} = date) do
    where(query, [r], field(r, ^key) < ^date)
  end
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :<, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) < ^value)
    end
  end

  def apply_filter(query, op, key, {:ym, year, month}) do
    query
    |> apply_filter(op, key, {:year, year})
    |> apply_filter(op, key, {:month, month})
  end
end
