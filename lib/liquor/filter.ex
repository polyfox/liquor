defmodule Liquor.Filter do
  @moduledoc """
  Applies search terms as filters to a given Ecto.Query
  """
  import Ecto.Query

  @type filter ::
    ((Ecto.Query.t, atom, atom, term) -> Ecto.Query.t) |
    map |
    {:apply, module, atom, list}

  @spec apply_filter(Ecto.Query.t, atom, atom, term, filter) :: Ecto.Query.t
  def apply_filter(query, _op, _key, _value, nil), do: query
  def apply_filter(query, op, key, value, filter) when is_function(filter) do
    filter.(query, op, key, value)
  end
  def apply_filter(query, :match, key, value, {:type, _, _} = spec) when is_list(value) do
    where(query, [r], field(r, ^key) in ^value)
  end
  def apply_filter(query, :unmatch, key, value, {:type, _, _} = spec) when is_list(value) do
    where(query, [r], field(r, ^key) not in ^value)
  end
  def apply_filter(query, op, key, value, {:type, _, _} = spec) when is_list(value) do
    Enum.reduce(value, query, fn str, q2 -> apply_filter(q2, op, key, str, spec) end)
  end
  def apply_filter(query, op, key, nil, {:type, _, %{null: false}}) do
    # the field is not nullable, doesn't matter what the operator is, if it's nil it can't filter
    query
  end
  def apply_filter(query, op, key, nil, {:type, _, _}) do
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
  def apply_filter(query, op, key, value, {:type, :date, _}) do
    Liquor.Filters.Date.apply_filter(query, op, key, value)
  end
  def apply_filter(query, op, key, value, {:type, :time, _}) do
    Liquor.Filters.Time.apply_filter(query, op, key, value)
  end
  def apply_filter(query, op, key, value, {:type, :naive_datetime, _}) do
    Liquor.Filters.NaiveDateTime.apply_filter(query, op, key, value)
  end
  def apply_filter(query, op, key, value, {:type, type, _}) when type in [:integer, :float, :decimal] do
    Liquor.Filters.Numeric.apply_filter(query, op, key, value)
  end
  def apply_filter(query, op, key, value, {:type, :string, _}) when is_binary(value) do
    Liquor.Filters.String.apply_filter(query, op, key, value)
  end
  def apply_filter(query, op, key, value, {:type, :atom, _}) when is_atom(value) do
    Liquor.Filters.Atom.apply_filter(query, op, key, value)
  end
  def apply_filter(query, op, key, value, {:type, :boolean, _}) when is_boolean(value) do
    Liquor.Filters.Atom.apply_filter(query, op, key, value)
  end
  def apply_filter(query, op, key, value, {:type, type}) do
    apply_filter(query, op, key, value, {:type, type, %{}})
  end
  def apply_filter(query, op, key, value, {:apply, m, f, a}) when is_atom(m) and is_atom(f) do
    :erlang.apply(m, f, [query, op, key, value | a])
  end

  def filter(query, terms, filter) when is_function(filter) do
    Enum.reduce(terms, query, fn
      {op, key, value}, q2 -> apply_filter(q2, op, key, value, filter)
    end)
  end
  def filter(query, terms, items) when is_map(items) do
    Enum.reduce(terms, query, fn
      {op, key, value}, q2 -> apply_filter(q2, op, key, value, items[key])
    end)
  end
  def filter(query, terms, {m, f, a}) when is_atom(m) and is_atom(f) do
    Enum.reduce(terms, query, fn
      {op, key, value}, q2 -> apply_filter(q2, op, key, value, {m, f, a})
    end)
  end
end
