defmodule Liquor.Lexer do
  # escaped quote
  defp do_tokenize_string("\\\"" <> rest, quote_char, acc) do
    do_tokenize_string(rest, quote_char, ["\"" | acc])
  end

  defp do_tokenize_string("\"" <> rest, "\"", acc) do
    result =
      acc
      |> Enum.reverse()
      |> Enum.join()
    {result, rest}
  end

  defp do_tokenize_string(<<char :: binary-size(1), rest :: binary>>, quote_char, acc) do
    do_tokenize_string(rest, quote_char, [char | acc])
  end

  def tokenize_string("\"" <> rest) do
    do_tokenize_string(rest, "\"", [])
  end

  def tokenize_word(str) do
    case String.split(str, ~r/\A([\w_\-\+\.]+)/, parts: 2, include_captures: true) do
      [_] -> nil
      [_, word, rest] -> {{:atom, word}, rest}
    end
  end

  defp space([:space | _acc] = acc), do: acc
  defp space(acc), do: [:space | acc]

  @spec do_tokenize(String.t, list, list) :: {[term], String.t}
  defp do_tokenize(<<>>, _state, acc), do: {Enum.reverse(acc), ""}
  defp do_tokenize("\r\n" <> rest, state, acc), do: do_tokenize(rest, state, space(acc))
  defp do_tokenize("\s" <> rest, state, acc), do: do_tokenize(rest, state, space(acc))
  defp do_tokenize("\t" <> rest, state, acc), do: do_tokenize(rest, state, space(acc))
  defp do_tokenize("\n" <> rest, state, acc), do: do_tokenize(rest, state, space(acc))
  defp do_tokenize(<<"\"", _rest :: binary>> = str, state, acc) do
    {result, rest} = tokenize_string(str)
    do_tokenize(rest, state, [{:string, result} | acc])
  end
  defp do_tokenize("==" <> rest, state, acc), do: do_tokenize(rest, state, [:eq | acc])
  defp do_tokenize("!=" <> rest, state, acc), do: do_tokenize(rest, state, [:neq | acc])
  defp do_tokenize("<=" <> rest, state, acc), do: do_tokenize(rest, state, [:leq | acc])
  defp do_tokenize(">=" <> rest, state, acc), do: do_tokenize(rest, state, [:geq | acc])
  defp do_tokenize(">" <> rest, state, acc), do: do_tokenize(rest, state, [:gt | acc])
  defp do_tokenize("<" <> rest, state, acc), do: do_tokenize(rest, state, [:lt | acc])
  defp do_tokenize("*" <> rest, state, acc), do: do_tokenize(rest, state, [:* | acc])
  defp do_tokenize("(" <> rest, state, acc) do
    {acc2, ")" <> rest2} = do_tokenize(rest, [:'(' | state], [])
    do_tokenize(rest2, state, [{:group, acc2} | acc])
  end
  defp do_tokenize(<<")", _rest :: binary>> = str, [:'(' | _state], acc) do
    {Enum.reverse(acc), str}
  end
  defp do_tokenize("[" <> rest, state, acc) do
    {acc2, "]" <> rest2} = do_tokenize(rest, [:'[' | state], [])
    do_tokenize(rest2, state, [{:list, acc2} | acc])
  end
  defp do_tokenize(<<"]", _rest :: binary>> = str, [:'[' | _state], acc) do
    {Enum.reverse(acc), str}
  end
  defp do_tokenize(str, state, acc) do
    case tokenize_word(str) do
      nil -> {Enum.reverse(acc), str}
      {token, rest} -> do_tokenize(rest, state, [token | acc])
    end
  end

  @spec tokenize(String.t) :: {[term], String.t}
  def tokenize(str) when is_binary(str) do
    do_tokenize(str, [], [])
  end
end
