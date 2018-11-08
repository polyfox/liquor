defmodule Liquor.Filters.Atom do
  @moduledoc """
  Handles atom filters, this also affects booleans
  """
  import Ecto.Query

  def apply_filter(query, op, key, value) do
    case op do
      :match -> where(query, [r], field(r, ^key) == ^value)
      :unmatch -> where(query, [r], field(r, ^key) != ^value)
      :== -> where(query, [r], field(r, ^key) == ^value)
      :!= -> where(query, [r], field(r, ^key) != ^value)
      :<= -> where(query, [r], field(r, ^key) == ^value)
      :>= -> where(query, [r], field(r, ^key) == ^value)
      :> -> where(query, [r], field(r, ^key) != ^value)
      :< -> where(query, [r], field(r, ^key) != ^value)
    end
  end
end
