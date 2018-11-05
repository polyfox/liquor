defmodule Liquor.LexerTest do
  use ExUnit.Case
  alias Liquor.Lexer

  describe "tokenize/1" do
    test "tokenizes given string" do
      assert {[
        {:atom, "ABC"}, :space,
        {:atom, "A-B_C"}, :space,
        {:string, "Hello, World"}, :space,
        {:group, [
          {:atom, "a"}, :space,
          {:atom, "b"}, :space,
          {:atom, "c"},
        ]}, :space,
        {:list, [
          {:atom, "d"}, :space,
          {:atom, "e"}, :space,
          {:atom, "f"},
        ]}, :space,
        {:atom, "g"}, :*, :space,
        :*, {:atom, "h"},
      ], ""} == Lexer.tokenize(~s|ABC A-B_C "Hello, World" (a b c) [d e f] g* *h|)
    end
  end
end
