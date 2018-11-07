defmodule Liquor.Whitelist do
  @moduledoc """
  Whitelist takes a list of search items and attempts to filter them
  """
  defp apply_filter(_op, _key, _value, nil), do: :reject
  defp apply_filter(_op, _key, _value, false), do: :reject
  defp apply_filter(op, key, value, true), do: {:ok, {op, key, value}}
  defp apply_filter(op, key, value, atom) when is_atom(atom), do: {:ok, {op, atom, value}}
  defp apply_filter(op, key, value, {m, f, a}) when is_atom(m) and is_atom(f) do
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

  @spec whitelist(list, map | ((atom, atom, term) :: {:ok, {atom, atom, term} | {atom, term}} | :reject)) :: list
  def whitelist(values, filter) when is_function(filter) do
    Enum.reduce(values, [], fn
      {op, key, value}, acc ->
        handle_item(apply_filter(op, key, value, filter), acc)
      {key, value}, acc ->
        handle_item(apply_filter(:match, key, value, filter), acc)
      value, acc ->
        handle_item(apply_filter(:match, nil, value, filter), acc)
    end)
  end

  def whitelist(values, map) when is_map(map) do
    whitelist(values, &(apply_filter(&1, &2, &3, map.items[&2])))
  end
end
