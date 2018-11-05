defmodule Liquor.Lexer do
  @moduledoc """
  Converts a given string into tokens for consumption
  """
  @type token ::
    {:atom, String.t} |
    {:string, String.t} |
    {:space, non_neg_integer} |
    {:eq, non_neg_integer} |
    {:neq, non_neg_integer} |
    {:lte, non_neg_integer} |
    {:gte, non_neg_integer} |
    {:gt, non_neg_integer} |
    {:lt, non_neg_integer} |
    {:*, non_neg_integer} |
    {:in, non_neg_integer} |
    {:and, non_neg_integer} |
    {:or, non_neg_integer}

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
    case String.split(str, ~r/\A([\w_\-\+\.\:]+)/, parts: 2, include_captures: true) do
      [_] -> nil
      [_, "IN", rest] -> {{:in, 1}, rest}
      [_, "AND", rest] -> {{:and, 1}, rest}
      [_, "OR", rest] -> {{:or, 1}, rest}
      [_, word, rest] -> {{:atom, word}, rest}
    end
  end

  defp space([:space | _acc] = acc), do: acc
  defp space(acc), do: [{:space, 1} | acc]

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
  defp do_tokenize("==" <> rest, state, acc), do: do_tokenize(rest, state, [{:eq, 1} | acc])
  defp do_tokenize("!=" <> rest, state, acc), do: do_tokenize(rest, state, [{:neq, 1} | acc])
  defp do_tokenize("<=" <> rest, state, acc), do: do_tokenize(rest, state, [{:lte, 1} | acc])
  defp do_tokenize(">=" <> rest, state, acc), do: do_tokenize(rest, state, [{:gte, 1} | acc])
  defp do_tokenize(">" <> rest, state, acc), do: do_tokenize(rest, state, [{:gt, 1} | acc])
  defp do_tokenize("<" <> rest, state, acc), do: do_tokenize(rest, state, [{:lt, 1} | acc])
  defp do_tokenize("*" <> rest, state, acc), do: do_tokenize(rest, state, [{:wc, 1} | acc])
  defp do_tokenize("~" <> rest, state, acc), do: do_tokenize(rest, state, [{:in, 1} | acc])
  defp do_tokenize("(" <> rest, state, acc) do
    do_tokenize(rest, [:'(' | state], [{:'(', 1} | acc])
  end
  defp do_tokenize(")" <> rest, [:'(' | state], acc) do
    do_tokenize(rest, state, [{:')', 1} | acc])
  end
  defp do_tokenize("[" <> rest, state, acc) do
    do_tokenize(rest, [:'[' | state], [{:'[', 1} | acc])
  end
  defp do_tokenize("]" <> rest, [:'[' | state], acc) do
    do_tokenize(rest, state, [{:']', 1} | acc])
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
