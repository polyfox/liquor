defmodule Liquor.Filters.Numeric do
  @moduledoc """
  Specialized module for filtering numeric fields
  """
  import Ecto.Query

  def apply_filter(query, op, key, value) do
    case op do
      :match -> where(query, [r], field(r, ^key) == ^value)
      :unmatch -> where(query, [r], field(r, ^key) != ^value)
      :== -> where(query, [r], field(r, ^key) == ^value)
      :!= -> where(query, [r], field(r, ^key) != ^value)
      :<= -> where(query, [r], field(r, ^key) <= ^value)
      :>= -> where(query, [r], field(r, ^key) >= ^value)
      :> -> where(query, [r], field(r, ^key) > ^value)
      :< -> where(query, [r], field(r, ^key) < ^value)
    end
  end
end
