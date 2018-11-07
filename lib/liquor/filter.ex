defmodule Liquor.Filter do
  import Ecto.Query

  @type filter ::
    ((Ecto.Query.t, atom, atom, term) -> Ecto.Query.t) |
    map |
    {:apply, module, atom, list}

  def escape_search_string(value, acc \\ {:static, []})
  def escape_search_string(<<>>, {state, acc}) do
    {state,
      acc
      |> Enum.reverse()
      |> Enum.join()}
  end
  def escape_search_string(<<"\\", c :: utf8, rest :: binary>>, {state, acc}) when c in ["*", "?"] do
    escape_search_string(rest, {state, [<<c>> | acc]})
  end
  def escape_search_string(<<"%", rest :: binary>>, {_state, acc}) do
    escape_search_string(rest, {:like, ["\\%" | acc]})
  end
  def escape_search_string(<<"_", rest :: binary>>, {_state, acc}) do
    escape_search_string(rest, {:like, ["\\_" | acc]})
  end
  def escape_search_string(<<"*", rest :: binary>>, {_state, ["%" | acc]}) do
    # skip excess wildcards
    escape_search_string(rest, {:like, acc})
  end
  def escape_search_string(<<"*", rest :: binary>>, {_state, acc}) do
    escape_search_string(rest, {:like, ["%" | acc]})
  end
  def escape_search_string(<<"?", rest :: binary>>, {_state, acc}) do
    escape_search_string(rest, {:like, ["_" | acc]})
  end
  def escape_search_string(<<c :: utf8, rest :: binary>>, {state, acc}) do
    escape_search_string(rest, {state, [<<c>> | acc]})
  end

  @spec apply_filter(Ecto.Query.t, atom, atom, term, filter) :: Ecto.Query.t
  def apply_filter(query, _op, _key, _value, nil) do
    query
  end
  def apply_filter(query, op, key, value, filter) when is_function(filter) do
    filter.(query, op, key, value)
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
  def apply_filter(query, op, key, value, {:type, type, _}) when type in [:integer, :float, :decimal] do
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
  def apply_filter(query, op, key, value, {:type, :string, _}) when is_binary(value) do
    case op do
      :match ->
        case escape_search_string(value) do
          {:like, "%"} -> query
          {:like, str} -> where(query, [b], like(field(b, ^key), str))
          {:static, str} -> where(query, [r], field(r, ^key) == ^value)
        end
      :unmatch ->
        case escape_search_string(value) do
          {:like, "%"} -> query
          {:like, str} -> where(query, [b], not like(field(b, ^key), str))
          {:static, str} -> where(query, [r], field(r, ^key) != ^value)
        end
      :== -> where(query, [r], field(r, ^key) == ^value)
      :!= -> where(query, [r], field(r, ^key) != ^value)
      :<= -> where(query, [r], field(r, ^key) <= ^value)
      :>= -> where(query, [r], field(r, ^key) >= ^value)
      :> -> where(query, [r], field(r, ^key) > ^value)
      :< -> where(query, [r], field(r, ^key) < ^value)
    end
  end
  def apply_filter(query, op, key, value, {:type, type}) do
    apply_filter(query, op, key, value, {:type, type, %{}})
  end
  def apply_filter(query, op, key, value, {:apply, m, f, a}) when when is_atom(m) and is_atom(f) do
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
