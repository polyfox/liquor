defmodule Liquor.Filters.Time do
  @moduledoc """
  Specialized module for filtering date fields
  """
  import Ecto.Query

  @allowed_fields [:hour, :minute, :second]

  def apply_filter(query, :match, key, %Time{} = time), do: apply_filter(query, :==, key, time)
  def apply_filter(query, :match, key, {atom, _year} = value) when atom in @allowed_fields, do: apply_filter(query, :==, key, value)

  def apply_filter(query, :unmatch, key, %Time{} = time), do: apply_filter(query, :!=, key, time)
  def apply_filter(query, :unmatch, key, {atom, _year} = value) when atom in @allowed_fields, do: apply_filter(query, :!=, key, value)

  def apply_filter(query, :==, key, %Time{} = time), do: where(query, [r], fragment("?::time", field(r, ^key)) == ^time)
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :==, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) == ^value)
    end
  end

  def apply_filter(query, :!=, key, %Time{} = time), do: where(query, [r], fragment("?::time", field(r, ^key)) != ^time)
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :!=, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) != ^value)
    end
  end

  def apply_filter(query, :>=, key, %Time{} = time), do: where(query, [r], fragment("?::time", field(r, ^key)) >= ^time)
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :>=, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) >= ^value)
    end
  end

  def apply_filter(query, :<=, key, %Time{} = time), do: where(query, [r], fragment("?::time", field(r, ^key)) <= ^time)
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :<=, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) <= ^value)
    end
  end

  def apply_filter(query, :>, key, %Time{} = time), do: where(query, [r], fragment("?::time", field(r, ^key)) > ^time)
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :>, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) > ^value)
    end
  end

  def apply_filter(query, :<, key, %Time{} = time), do: where(query, [r], fragment("?::time", field(r, ^key)) < ^time)
  for comp <- @allowed_fields do
    frag = "EXTRACT(#{comp} FROM ?)"
    def apply_filter(query, :<, key, {unquote(comp), value}) do
      where(query, [r], fragment(unquote(frag), field(r, ^key)) < ^value)
    end
  end
end
