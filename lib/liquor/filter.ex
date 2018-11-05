defmodule Liquor.Filter do
  def filter(query, _spec, nil) do
    query
  end
  def filter(query, spec, string) when is_binary(string) do
    case Liquor.Parser.parse(string) do
      {:ok, exp} -> filter(query, spec, exp)
    end
  end
  def filter(query, spec, exp) do
  end
end
