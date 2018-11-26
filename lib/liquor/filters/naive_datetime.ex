defmodule Liquor.Filters.NaiveDateTime do
  @moduledoc """
  Specialized module for filtering timestamp fields
  """
  import Ecto.Query

  @allowed_fields [:year, :month, :day, :hour, :minute, :second, :microsecond]

  def apply_filter(query, :match, key, %Date{} = date), do: apply_filter(query, :==, key, date)
  #def apply_filter(query, :match, key, %DateTime{} = datetime), do: apply_filter(query, :==, key, datetime)
  def apply_filter(query, :match, key, %NaiveDateTime{} = datetime), do: apply_filter(query, :==, key, datetime)
  def apply_filter(query, :match, key, {atom, _year} = value) when atom in @allowed_fields, do: apply_filter(query, :==, key, value)
  def apply_filter(query, :match, key, {:ym, _year, _month} = value), do: apply_filter(query, :==, key, value)

  def apply_filter(query, :unmatch, key, %Date{} = date), do: apply_filter(query, :!=, key, date)
  #def apply_filter(query, :unmatch, key, %DateTime{} = datetime), do: apply_filter(query, :!=, key, datetime)
  def apply_filter(query, :unmatch, key, %NaiveDateTime{} = datetime), do: apply_filter(query, :!=, key, datetime)
  def apply_filter(query, :unmatch, key, {atom, _year} = value) when atom in @allowed_fields, do: apply_filter(query, :!=, key, value)
  def apply_filter(query, :unmatch, key, {:ym, _year, _month} = value), do: apply_filter(query, :!=, key, value)

  def apply_filter(query, :==, key, %Date{} = date), do: where(query, [r], fragment("?::date", field(r, ^key)) == ^date)
  #def apply_filter(query, :==, key, %DateTime{} = datetime), do: where(query, [r], field(r, ^key) == ^datetime)
  def apply_filter(query, :==, key, %NaiveDateTime{} = datetime), do: where(query, [r], field(r, ^key) == ^datetime)
  def apply_filter(query, :==, key, {:ym, year, month}) do
    query
    |> apply_filter(:==, key, {:year, year})
    |> apply_filter(:==, key, {:month, month})
  end
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :==, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) == ^value)
    end
  end

  def apply_filter(query, :!=, key, %Date{} = date), do: where(query, [r], fragment("?::date", field(r, ^key)) != ^date)
  #def apply_filter(query, :!=, key, %DateTime{} = datetime), do: where(query, [r], field(r, ^key) != ^datetime)
  def apply_filter(query, :!=, key, %NaiveDateTime{} = datetime), do: where(query, [r], field(r, ^key) != ^datetime)
  def apply_filter(query, :!=, key, {:ym, year, month}) do
    query
    |> apply_filter(:!=, key, {:year, year})
    |> apply_filter(:!=, key, {:month, month})
  end
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :!=, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) != ^value)
    end
  end

  def apply_filter(query, :>=, key, %Date{} = date), do: where(query, [r], fragment("?::date", field(r, ^key)) >= ^date)
  def apply_filter(query, :>=, key, %NaiveDateTime{} = datetime), do: where(query, [r], field(r, ^key) >= ^datetime)
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :>=, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) >= ^value)
    end
  end

  def apply_filter(query, :<=, key, %Date{} = date), do: where(query, [r], fragment("?::date", field(r, ^key)) <= ^date)
  def apply_filter(query, :<=, key, %NaiveDateTime{} = datetime), do: where(query, [r], field(r, ^key) <= ^datetime)
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :<=, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) <= ^value)
    end
  end

  def apply_filter(query, :>, key, %Date{} = date), do: where(query, [r], fragment("?::date", field(r, ^key)) > ^date)
  def apply_filter(query, :>, key, %NaiveDateTime{} = datetime), do: where(query, [r], field(r, ^key) > ^datetime)
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :>, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) > ^value)
    end
  end

  def apply_filter(query, :<, key, %Date{} = date), do: where(query, [r], fragment("?::date", field(r, ^key)) < ^date)
  def apply_filter(query, :<, key, %NaiveDateTime{} = datetime), do: where(query, [r], field(r, ^key) < ^datetime)
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :<, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) < ^value)
    end
  end
end
