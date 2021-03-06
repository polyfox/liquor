defmodule Liquor.Transformer do
  @moduledoc """
  Transformer takes a list of search items and tries to
  """
  @type spec_item ::
    {:apply, module, atom, list} |
    {:mod, module} |
    {:type, atom} |
    atom |
    ((atom, atom, term) -> {:ok, {atom, atom, term}} | :error)

  @type type_spec :: %{ atom => spec_item }

  @spec transform_value(term, Liquor.op, atom, spec_item) :: {:ok, {atom, atom, term}} | :error
  defp transform_value(value, op, key, {:mod, module}) do
    case module.cast(value) do
      {:ok, new_value} -> {:ok, {op, key, new_value}}
      :error -> :error
      {:error, _} = err -> err
    end
  end
  defp transform_value(value, op, key, {:apply, m, f, a}) when is_atom(m) and is_atom(f) do
    :erlang.apply(m, f, [op, key, value | a])
  end
  defp transform_value(value, op, key, f) when is_function(f) do
    f.(op, key, value)
  end
  defp transform_value(value, op, key, :boolean) do
    case Liquor.Transformers.Boolean.transform(value) do
      {:ok, new_value} -> {:ok, {op, key, new_value}}
      :error -> :error
    end
  end
  defp transform_value(value, op, key, {:type, :date}) do
    case Liquor.Transformers.Date.transform(value) do
      {:ok, new_value} -> {:ok, {op, key, new_value}}
      :error -> :error
    end
  end
  defp transform_value(value, op, key, {:type, :naive_datetime}) do
    case Liquor.Transformers.NaiveDateTime.transform(value) do
      {:ok, new_value} -> {:ok, {op, key, new_value}}
      :error -> :error
    end
  end
  defp transform_value(value, op, key, {:type, :time}) do
    case Liquor.Transformers.Time.transform(value) do
      {:ok, new_value} -> {:ok, {op, key, new_value}}
      :error -> :error
    end
  end
  defp transform_value(value, op, key, {:type, type}) when is_atom(type) do
    case Ecto.Type.cast(type, value) do
      {:ok, new_value} -> {:ok, {op, key, new_value}}
      :error -> :error
    end
  end

  @doc """
  Transforms the given keywords or pairs into their search specs

  It is expected that the values provided have already been whitelisted or renamed as needed
  """
  @spec transform(list | map, type_spec) :: list
  def transform(values, spec) do
    Enum.reduce(values, [], fn
      {op, key, value}, acc ->
        if Map.has_key?(spec, key) do
          {:ok, new_value} = transform_value(value, op, key, spec[key])
          [new_value | acc]
        else
          acc
        end
      {key, value}, acc ->
        if Map.has_key?(spec, key) do
          {:ok, new_value} = transform_value(value, :match, key, spec[key])
          [new_value | acc]
        else
          acc
        end
      value, acc ->
        if spec.keyword do
          {:ok, new_value} = transform_value(value, :match, nil, spec._)
          [new_value | acc]
        else
          acc
        end
    end)
    |> Enum.reverse()
  end
end
