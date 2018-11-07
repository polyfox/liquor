defmodule Liquor do
  @type search_spec :: %{
    whitelist: Liquor.Whitelist.filter(),
    transform: Liquor.Transformer.type_spec(),
    filter: Liquor.Filter.filter(),
  }

  @spec parse_string(String.t) :: {:ok, list} | {:error, term}
  def parse_string(string), do: Liquor.Parser.parse(string, parse_operators: true)

  @spec whitelist_terms(list, Liquor.Whitelist.filter()) :: list
  def whitelist_terms(terms, filter), do: Liquor.Whitelist.whitelist(terms, filter)

  @spec transform_terms(list, Liquor.Transformer.type_spec()) :: list
  def transform_terms(terms, type_spec), do: Liquor.Transformer.transform(terms, type_spec)

  @spec filter_terms(Ecto.Query.t, list, Liquor.Filter.filter()) :: Ecto.Query.t
  def filter_terms(query, terms, filter), do: Liquor.Filter.filter(query, terms, filter)

  @spec prepare_terms(String.t, search_spec) :: {:ok, list} | {:error, term}
  def prepare_terms(string, spec) when is_binary(string) do
    case parse_string(string) do
      {:ok, terms} -> prepare_terms(terms, spec)
      {:error, _} = err -> err
    end
  end
  def prepare_terms(terms, spec) when is_map(terms) do
    prepare_terms(Map.to_list(terms), spec)
  end
  def prepare_terms(terms, spec) when is_list(terms) do
    terms = whitelist_terms(terms, spec.whitelist)
    terms = transform_terms(terms, spec.transform)
    {:ok, terms}
  end

  @spec apply_search(Ecto.Query.t, String.t | list, search_spec) :: Ecto.Query.t
  def apply_search(query, string, spec) when is_binary(string) do
    {:ok, terms} = prepare_terms(string, spec)
    apply_search(query, terms, spec)
  end
  def apply_search(query, terms, spec) when is_map(terms) do
    apply_search(query, Map.to_list(terms), spec)
  end
  def apply_search(query, terms, spec) when is_list(terms) do
    query
    |> filter_terms(terms, spec.filter)
  end
end
