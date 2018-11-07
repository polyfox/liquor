defmodule Liquor.Filters.DateTime do
  @moduledoc """
  Specialized module for filtering date fields
  """
  import Ecto.Query

  def apply_filter(query, :match, key, %Date{} = date), do: apply_filter(query, :==, key, date)
  def apply_filter(query, :match, key, %DateTime{} = datetime), do: apply_filter(query, :==, key, datetime)
  def apply_filter(query, :match, key, %NaiveDateTime{} = datetime), do: apply_filter(query, :==, key, datetime)
  def apply_filter(query, :match, key, {:year, _year} = value), do: apply_filter(query, :==, key, value)
  def apply_filter(query, :match, key, {:month, _month} = value), do: apply_filter(query, :==, key, value)
  def apply_filter(query, :match, key, {:day, _day} = value), do: apply_filter(query, :==, key, value)
  def apply_filter(query, :match, key, {:hour, _hour} = value), do: apply_filter(query, :==, key, value)
  def apply_filter(query, :match, key, {:minute, _minute} = value), do: apply_filter(query, :==, key, value)
  def apply_filter(query, :match, key, {:second, _second} = value), do: apply_filter(query, :==, key, value)
  def apply_filter(query, :match, key, {:ym, _year, _month} = value), do: apply_filter(query, :==, key, value)

  def apply_filter(query, :unmatch, key, %Date{} = date), do: apply_filter(query, :!=, key, date)
  def apply_filter(query, :unmatch, key, %DateTime{} = datetime), do: apply_filter(query, :!=, key, datetime)
  def apply_filter(query, :unmatch, key, %NaiveDateTime{} = datetime), do: apply_filter(query, :!=, key, datetime)
  def apply_filter(query, :unmatch, key, {:year, _year} = value), do: apply_filter(query, :!=, key, value)
  def apply_filter(query, :unmatch, key, {:month, _month} = value), do: apply_filter(query, :!=, key, value)
  def apply_filter(query, :unmatch, key, {:day, _day} = value), do: apply_filter(query, :!=, key, value)
  def apply_filter(query, :unmatch, key, {:hour, _hour} = value), do: apply_filter(query, :!=, key, value)
  def apply_filter(query, :unmatch, key, {:minute, _minute} = value), do: apply_filter(query, :!=, key, value)
  def apply_filter(query, :unmatch, key, {:second, _second} = value), do: apply_filter(query, :!=, key, value)
  def apply_filter(query, :unmatch, key, {:ym, _year, _month} = value), do: apply_filter(query, :!=, key, value)

  @allowed_fields [:year, :month, :day, :hour, :minute, :second]
  def apply_filter(query, :==, key, %Date{} = date) do
    where(query, [r], fragment("?::date", field(r, ^key)) == ^date)
  end
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :==, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) == ^value)
    end
  end

  def apply_filter(query, :!=, key, %Date{} = date) do
    where(query, [r], fragment("?::date", field(r, ^key)) != ^date)
  end
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :!=, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) != ^value)
    end
  end

  def apply_filter(query, :>=, key, %Date{} = date) do
    where(query, [r], fragment("?::date", field(r, ^key)) >= ^date)
  end
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :>=, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) >= ^value)
    end
  end

  def apply_filter(query, :<=, key, %Date{} = date) do
    where(query, [r], fragment("?::date", field(r, ^key)) <= ^date)
  end
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :<=, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) <= ^value)
    end
  end

  def apply_filter(query, :>, key, %Date{} = date) do
    where(query, [r], fragment("?::date", field(r, ^key)) > ^date)
  end
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :>, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) > ^value)
    end
  end

  def apply_filter(query, :<, key, %Date{} = date) do
    where(query, [r], fragment("?::date", field(r, ^key)) < ^date)
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
