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

    test "parses a double-quoted key" do
      assert {:ok, [{"abc", "def"}]} == P.parse("\"abc\":def")
    end

    test "parses a single-quoted key" do
      assert {:ok, [{"abc", "def"}]} == P.parse("'abc':def")
    end

    test "parses a mixed keyword" do
      assert {:ok, ["hello-world"]} == P.parse(~s("hello"-"world"))
    end

    test "parses a blank value" do
      assert {:ok, [{"key", nil}, "value"]} == P.parse(~s(key: value))
    end

    test "parses operator prefixes on key" do
      assert {:ok, [{"==key", "value"}]} == P.parse(~s(==key:value))
      assert {:ok, [{"!=key", "value"}]} == P.parse(~s(!=key:value))
      assert {:ok, [{">=key", "value"}]} == P.parse(~s(>=key:value))
      assert {:ok, [{"<=key", "value"}]} == P.parse(~s(<=key:value))
      assert {:ok, [{"<key", "value"}]} == P.parse(~s(<key:value))
      assert {:ok, [{">key", "value"}]} == P.parse(~s(>key:value))
      assert {:ok, [{"!key", "value"}]} == P.parse(~s(!key:value))
      assert {:ok, [{"-key", "value"}]} == P.parse(~s(-key:value))
    end

    test "parses multiple items" do
      assert {:ok, [
        {"abc", "def"},
        "word",
        "word2",
        {"xyz", "230"},
        {"123", "helo world"},
        {"array", ~w[1 2 3 4]},
        {"ary", ["hello,we", "are", "barely", "alive"]},
        "word3",
        {"date", "2017/05/02-2017/05/03"},
      ]} == P.parse(~s(    abc:def word    word2      "xyz":230 123:"helo world" array:1,2,3,4 ary:"hello,we",are,"barely",alive word3 date:2017/05/02-2017/05/03))
    end

    test "only treats the first value before a colon as the field and everything else is the term" do
      assert {:ok, [{"key", "term:term2:term3:4:5:6"}]} == P.parse(~s(key:term:term2:term3:4:5:6))
    end

    test "will return an error if a malformed string is given" do
      # open string
      assert {:error, :unclosed_string} == P.parse(~s("))
      assert {:error, :unclosed_string} == P.parse(~s('"))
      assert {:error, :unclosed_string} == P.parse(~s("'))
    end
  end
end
