defmodule Liquor.Parser do
  @moduledoc """
  Utility module for parsing search query strings
  """
  def unquote_string("'" <> rest), do: String.trim_trailing(rest, "'")
  def unquote_string("\"" <> rest), do: String.trim_trailing(rest, "\"")
  def unquote_string(rest), do: rest

  defp parse_dstring_body(<<>>, _acc) do
    {:error, :unclosed_string}
  end
  defp parse_dstring_body(<<"\"", _ :: binary>> = rest, acc) do
    result =
      acc
      |> Enum.reverse()
      |> Enum.join()
    {:ok, result, rest}
  end
  defp parse_dstring_body("\\\"" <> rest, acc) do
    parse_dstring_body(rest, ["\"" | acc])
  end
  defp parse_dstring_body(<<c :: utf8, rest :: binary>>, acc) do
    parse_dstring_body(rest, [<<c>> | acc])
  end

  defp parse_sstring_body(<<>>, _acc) do
    {:error, :unclosed_string}
  end
  defp parse_sstring_body(<<"'", _ :: binary>> = rest, acc) do
    result =
      acc
      |> Enum.reverse()
      |> Enum.join()
    {:ok, result, rest}
  end
  defp parse_sstring_body("\\'" <> rest, acc) do
    parse_sstring_body(rest, ["'" | acc])
  end
  defp parse_sstring_body(<<c :: utf8, rest :: binary>>, acc) do
    parse_sstring_body(rest, [<<c>> | acc])
  end

  @spec parse_string(String.t, Keyword.t) :: {:ok, String.t, String.t}
  def parse_string(<<"\"", rest :: binary>>, options) do
    case parse_dstring_body(rest, []) do
      {:ok, str, "\"" <> rest} ->
        case options[:value_format] do
          :raw -> {:ok, str, rest}
          :strip -> {:ok, unquote_string(str), rest}
        end
      {:error, _} = err -> err
    end
  end

  def parse_string(<<"'", rest :: binary>>, options) do
    case parse_sstring_body(rest, []) do
      {:ok, str, "'" <> rest} ->
        case options[:value_format] do
          :raw -> {:ok, str, rest}
          :strip -> {:ok, unquote_string(str), rest}
        end
      {:error, _} = err -> err
    end
  end

  @spec parse_term(value :: binary, options :: Keyword.t) :: {:ok, String.t, String.t} | {:error, term}
  def parse_term(<<"\"", _rest :: binary>> = str, options), do: parse_string(str, options)
  def parse_term(<<"\'", _rest :: binary>> = str, options), do: parse_string(str, options)
  def parse_term(value, options) do
    case Regex.split(~r/\A("([^"]*)"|'([^']*)'|[^\s,'"]+)/, value, include_captures: true) do
      [_, value, rest] ->
        case options[:value_format] do
          :raw -> {:ok, value, rest}
          :strip -> {:ok, unquote_string(value), rest}
        end

      [_] -> {:error, {:invalid_value, value}}
    end
  end

  defp commit_value([], acc, _options), do: acc
  defp commit_value(value_acc, acc, options) do
    case options[:commit_format] do
      :raw -> [Enum.reverse(value_acc) | acc]
      :join ->
        result =
          value_acc
          |> Enum.reverse()
          |> Enum.join()
        [result | acc]
    end
  end

  @spec parse_terms(value :: binary,
    value_acc :: list,
    acc :: list,
    options :: Keyword.t) :: {:ok, list, String.t} | {:error, term}
  defp parse_terms(value, value_acc, acc, options)
  defp parse_terms(<<>>, value_acc, acc, options) do
    result =
      value_acc
      |> commit_value(acc, options)
      |> Enum.reverse()
    {:ok, result, ""}
  end
  defp parse_terms(<<" ", rest :: binary>>, value_acc, acc, options) do
    result =
      value_acc
      |> commit_value(acc, options)
      |> Enum.reverse()
    {:ok, result, rest}
  end
  defp parse_terms(<<",", rest :: binary>>, value_acc, acc, options) do
    parse_terms(rest, [], commit_value(value_acc, acc, options), options)
  end
  defp parse_terms(value, value_acc, acc, options) do
    case parse_term(value, options) do
      {:ok, value, rest} ->
        parse_terms(rest, [value | value_acc], acc, options)

      {:error, _} = err -> err
    end
  end

  defp unwrap_list([]), do: nil
  defp unwrap_list([value]), do: value
  defp unwrap_list(value), do: value

  defp handle_values(values, options) do
    case options[:values_format] do
      :raw -> values
      :unwrap -> unwrap_list(values)
    end
  end

  defp parse_operator(string, options) do
    case options[:parse_operators] do
      true ->
        case string do
          "==" <> rest -> {:==, rest}
          "!=" <> rest -> {:!=, rest}
          ">=" <> rest -> {:>=, rest}
          "<=" <> rest -> {:<=, rest}
          ">" <> rest -> {:>, rest}
          "<" <> rest -> {:<, rest}
          rest -> {:match, rest}
        end
      _ -> {nil, string}
    end
  end

  defp cleanup_key(key, options) do
    key = String.trim_trailing(key, ":")
    case options[:key_format] do
      :raw -> key
      :strip -> unquote_string(key)
    end
  end

  @spec parse_key(String.t, Keyword.t) :: {:ok, String.t, String.t} | {:error, :not_key}
  def parse_key(<<char :: binary-size(1), _ :: binary>> = str, options) when char in ["\"", "'"] do
    case parse_string(str, options) do
      {:ok, key, ":" <> rest} ->
        key = cleanup_key(key, options)
        {:ok, key, rest}
      _ -> {:error, :not_key}
    end
  end
  def parse_key(str, options) do
    case String.split(str, ~r/\A([^\s,:"']+):/, include_captures: true, split: 2) do
      [_, key, rest] ->
        key = cleanup_key(key, options)
        {:ok, key, rest}
      [_] -> {:error, :not_key}
    end
  end

  defp do_parse_raw(<<>>, acc, _options) do
    acc
    |> Enum.reverse()
    |> List.flatten()
  end

  defp do_parse_raw(value, acc, options) do
    value = String.trim_leading(value)
    case parse_key(value, options) do
      {:ok, key, rest} ->
        {op, rest} = parse_operator(rest, options)
        case parse_terms(rest, [], [], options) do
          {:ok, values, rest} ->
            values = handle_values(values, options)
            value = case op do
              nil -> {key, values}
              op -> {op, key, values}
            end
            do_parse_raw(rest, [value | acc], options)

          {:error, _} = err -> err
        end
      {:error, :not_key} ->
        case parse_terms(value, [], [], options) do
          {:ok, values, rest} ->
            do_parse_raw(rest, [handle_values(values, options) | acc], options)

          {:error, _} = err -> err
        end
    end
  end

  @doc """
  Parses a search query string, this will only perform a raw parse, and split
  the query into keywords and terms.

  Args:
  * `value` - the string to parse
  * `options` - various options that can affect the parsing

  Options:
  * `parse_operators` - parses additional operators right after the :
    - true - parse the operators (i.e. ==, !=, >=, <=, <, >)
    - false - do not parse the operators, they will be returned as apart of the value
  * `key_format` - affects how keys in a keyword pair are formatted
    - :raw - return the key as found in the search query
    - :strip - strip any quote pairs in the string
  * `commit_format` - affects how values are committed, by default they are joined
    - :raw - return the committed value as is, maintaining it's parts
    - :join - join the parts together to form a new binary
  * `value_format` - affects how a value is processed
    - :raw - return the value as parsed, this will keep any quotes
    - :strip - strip any quote pairs in the string
  * `values_format` - affects how values are returned
    - :raw - do not process the value
    - :unwrap - if the list is empty, return nil,
                if the list contains one element, return that element,
                otherwise return the list
  """
  @spec parse(String.t, Keyword.t) :: {:ok, list} | {:error, term}
  def parse(value, options \\ []) do
    options = Keyword.merge([
      parse_operators: false,
      key_format: :strip,
      commit_format: :join,
      value_format: :strip,
      values_format: :unwrap,
    ], options)
    case do_parse_raw(value, [], options) do
      list when is_list(list) -> {:ok, list}
      {:error, _reason} = err -> err
    end
  end
end
