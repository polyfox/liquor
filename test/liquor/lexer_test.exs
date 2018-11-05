defmodule Liquor.LexerTest do
  use ExUnit.Case
  alias Liquor.Lexer

  describe "tokenize/1" do
    test "tokenizes given string" do
      assert {[
        {:atom, "ABC"}, {:space, 1}, {:eq, 1}, {:space, 1}, {:atom, "A-B_C"}, {:space, 1},
        {:string, "Hello, World"}, {:space, 1},
        {:'(', 1},
          {:atom, "a"}, {:space, 1},
          {:atom, "b"}, {:space, 1},
          {:atom, "c"},
        {:')', 1}, {:space, 1},
        {:'[', 1},
          {:atom, "d"}, {:space, 1},
          {:atom, "e"}, {:space, 1},
          {:atom, "f"},
        {:']', 1}, {:space, 1},
        {:atom, "g"}, {:wc, 1}, {:space, 1},
        {:wc, 1}, {:atom, "h"}, {:space, 1},
        {:atom, "x"}, {:in, 1}, {:atom, "y"},
      ], ""} == Lexer.tokenize(~s|ABC == A-B_C "Hello, World" (a b c) [d e f] g* *h x~y|)
    end
  end
end
