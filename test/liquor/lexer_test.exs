defmodule Liquor.LexerTest do
  use ExUnit.Case
  alias Liquor.Lexer

  describe "tokenize/1" do
    test "tokenizes given string" do
      assert {[
        {:atom, "ABC"}, :space,
        {:string, "ABC"}, :space,
        {:group, [
          {:atom, "a"}, :space,
          {:atom, "b"}, :space,
          {:atom, "c"},
        ]}, :space,
        {:list, [
          {:atom, "d"}, :space,
          {:atom, "e"}, :space,
          {:atom, "f"},
        ]},
      ], ""} == Lexer.tokenize(~s|ABC "ABC" (a b c) [d e f]|)
    end
  end
end
