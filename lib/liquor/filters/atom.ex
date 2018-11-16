defmodule Liquor.Filters.Atom do
  @moduledoc """
  Handles atom filters, that is any value that can be reduced to a binary operation (== or !=)

  This can be used for enums, strings (that do not use partial matching), booleans.
  """
  import Ecto.Query

  @spec apply_filter(Ecto.Query.t, Liquor.op, atom, term) :: Ecto.Query.t
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
