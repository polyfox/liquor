defmodule Liquor.Filters.Null do
  import Ecto.Query

  @spec apply_filter(Ecto.Query.t, Liquor.op, atom, nil) :: Ecto.Query.t
  def apply_filter(query, op, key, nil) do
    # the field allows nils, and the field is currently nil
    case op do
      :match -> where(query, [r], is_nil(field(r, ^key)))
      :unmatch -> where(query, [r], not is_nil(field(r, ^key)))
      :== -> where(query, [r], is_nil(field(r, ^key)))
      :!= -> where(query, [r], not is_nil(field(r, ^key)))
      # these shouldn't even work
      :<= -> where(query, [r], is_nil(field(r, ^key)))
      :>= -> where(query, [r], is_nil(field(r, ^key)))
      :> -> where(query, [r], not is_nil(field(r, ^key)))
      :< -> where(query, [r], not is_nil(field(r, ^key)))
    end
  end
end
