defmodule Liquor.Filters.Date do
  @moduledoc """
  Specialized module for filtering date fields
  """
  import Ecto.Query

  @allowed_fields [:year, :month, :day]
  def apply_filter(query, :match, key, %Date{} = date), do: apply_filter(query, :==, key, date)
  def apply_filter(query, :match, key, {atom, _year} = value) when atom in @allowed_fields, do: apply_filter(query, :==, key, value)
  def apply_filter(query, :match, key, {:ym, _year, _month} = value), do: apply_filter(query, :==, key, value)

  def apply_filter(query, :unmatch, key, %Date{} = date), do: apply_filter(query, :!=, key, date)
  def apply_filter(query, :unmatch, key, {atom, _year} = value) when atom in @allowed_fields, do: apply_filter(query, :!=, key, value)
  def apply_filter(query, :unmatch, key, {:ym, _year, _month} = value), do: apply_filter(query, :!=, key, value)


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
