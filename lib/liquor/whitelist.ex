defmodule Liquor.Whitelist do
  @moduledoc """
  Whitelist takes a list of search items and attempts to filter them
  """
  @type filter_func :: ((atom, atom, term) -> {:ok, {atom, atom, term} | {atom, term}} | :reject)
  @type filter_item ::
    nil |
    boolean |
    atom |
    {:apply, module, atom, list} |
    filter_func
  @type filter :: %{String.t => filter_item} | filter_func

  defp invert_op(:match), do: :unmatch
  defp invert_op(:unmatch), do: :match
  defp invert_op(:>=), do: :<
  defp invert_op(:<=), do: :>
  defp invert_op(:<), do: :>=
  defp invert_op(:>), do: :<=
  defp invert_op(:==), do: :!=
  defp invert_op(:!=), do: :==

  defp apply_filter(op, key, value, filter) when is_atom(key) do
    # somewhat normalize the input
    apply_filter(op, Atom.to_string(key), value, filter)
  end
  defp apply_filter(op, "-" <> key, value, filter) do
    apply_filter(invert_op(op), key, value, filter)
  end
  defp apply_filter(op, "!" <> key, value, filter) do
    apply_filter(invert_op(op), key, value, filter)
  end
  defp apply_filter(_op, _key, _value, nil), do: :reject
  defp apply_filter(_op, _key, _value, false), do: :reject
  defp apply_filter(op, key, value, true), do: {:ok, {op, String.to_atom(key), value}}
  defp apply_filter(op, _key, value, atom) when is_atom(atom), do: {:ok, {op, atom, value}}
  defp apply_filter(op, key, value, {:apply, m, f, a}) when is_atom(m) and is_atom(f) do
    :erlang.apply(m, f, [op, key, value | a])
  end
  defp apply_filter(op, key, value, filter) when is_function(filter) do
    filter.(op, key, value)
  end

  defp handle_item(:reject, acc), do: acc
  defp handle_item({:ok, {op, key, _value} = item}, acc) when is_atom(op) and is_atom(key) do
    [item | acc]
  end
  defp handle_item({:ok, {key, value}}, acc) when is_atom(key) do
    [{:match, key, value} | acc]
  end

  @spec whitelist(list, filter) :: list
  def whitelist(terms, filter) when is_function(filter) do
    Enum.reduce(terms, [], fn
      {op, key, value}, acc ->
        handle_item(apply_filter(op, key, value, filter), acc)
      {key, value}, acc ->
        handle_item(apply_filter(:match, key, value, filter), acc)
      value, acc ->
        handle_item(apply_filter(:match, :_, value, filter), acc)
    end)
    |> Enum.reverse()
  end
  def whitelist(terms, filter_spec) when is_map(filter_spec) do
    whitelist(terms, &apply_filter(&1, &2, &3, filter_spec[&2]))
  end
end
