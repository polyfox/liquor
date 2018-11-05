defmodule Liquor.Parser do
  @spec parse(String.t | [Liquor.Lexer.token()]) :: {:ok, term}
  def parse(tokens) when is_list(tokens) do
    :liquor_parser.parse(tokens)
  end

  def parse(str) when is_binary(str) do
    {tokens, _} = Liquor.Lexer.tokenize(str)
    parse(tokens)
  end
end
