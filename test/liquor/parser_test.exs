defmodule Liquor.ParserTest do
  use ExUnit.Case

  describe "parse/1" do
    test "parses an expression" do
      assert {tokens, ""} = Liquor.Lexer.tokenize("inserted_at >= 2018-06-09")
      {:ok, result} = Liquor.Parser.parse(tokens)
      assert {:expression, {:gte, {:atom, "inserted_at"}, {:atom, "2018-06-09"}}} == result
    end

    test "parses a series of expressions" do
      assert {tokens, ""} = Liquor.Lexer.tokenize("inserted_at >= 2018-06-09 AND updated_at <= 2019-06-23")
      {:ok, result} = Liquor.Parser.parse(tokens)
      assert {
        {:expression, {:gte, {:atom, "inserted_at"}, {:atom, "2018-06-09"}}},
        :AND,
        {:expression, {:lte, {:atom, "updated_at"}, {:atom, "2019-06-23"}}}
      } == result
    end

    test "parses a group of expressions" do
      {:ok, result} = Liquor.Parser.parse("(a == b)")

      assert {:group, {:expression, {:eq, {:atom, "a"}, {:atom, "b"}}}} == result
    end
  end
end
