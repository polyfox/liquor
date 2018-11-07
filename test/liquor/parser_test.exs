defmodule Liquor.ParserTest do
  use ExUnit.Case
  alias Liquor.Parser, as: P

  describe "parse/2" do
    test "parses an empty string" do
      assert {:ok, []} == P.parse("")
    end

    test "parses an empty double-quoted string" do
      assert {:ok, [""]} == P.parse("\"\"")
    end

    test "parses an empty single-quoted string" do
      assert {:ok, [""]} == P.parse("''")
    end

    test "parses a basic term" do
      assert {:ok, ["abc"]} == P.parse("abc")
    end

    test "parses a complex term" do
      assert {:ok, ["abc-def"]} == P.parse("abc-def")
    end

    test "parses a key-value pair" do
      assert {:ok, [{"abc", "def"}]} == P.parse("abc:def")
    end

    test "parses a double-quoted key pair" do
      assert {:ok, [{"abc", "def"}]} == P.parse("\"abc\":def")
    end

    test "parses a single-quoted key pair" do
      assert {:ok, [{"abc", "def"}]} == P.parse("'abc':def")
    end
  end
end
