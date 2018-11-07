defmodule Liquor.Filters.String do
  @moduledoc """
  Specialized module for filtering numeric fields
  """
  import Ecto.Query

  def escape_search_string(value, acc \\ {:static, []})
  def escape_search_string(<<>>, {state, acc}) do
    {state,
      acc
      |> Enum.reverse()
      |> Enum.join()}
  end
  def escape_search_string(<<"\\*", rest :: binary>>, {state, acc}) do
    escape_search_string(rest, {state, ["*" | acc]})
  end
  def escape_search_string(<<"\\?", rest :: binary>>, {state, acc}) do
    escape_search_string(rest, {state, ["?" | acc]})
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

  def apply_filter(query, op, key, value) do
    case op do
      :match ->
        case escape_search_string(value) do
          {:like, "%"} -> query
          {:like, str} -> where(query, [b], like(field(b, ^key), ^str))
          {:static, str} -> where(query, [r], field(r, ^key) == ^str)
        end
      :unmatch ->
        case escape_search_string(value) do
          {:like, "%"} -> query
          {:like, str} -> where(query, [b], not like(field(b, ^key), ^str))
          {:static, str} -> where(query, [r], field(r, ^key) != ^str)
        end
      :== -> where(query, [r], field(r, ^key) == ^value)
      :!= -> where(query, [r], field(r, ^key) != ^value)
      :<= -> where(query, [r], field(r, ^key) <= ^value)
      :>= -> where(query, [r], field(r, ^key) >= ^value)
      :> -> where(query, [r], field(r, ^key) > ^value)
      :< -> where(query, [r], field(r, ^key) < ^value)
    end
  end
end
