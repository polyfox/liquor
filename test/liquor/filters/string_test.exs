defmodule Liquor.Filters.StringTest do
  use Liquor.Support.DataCase
  alias Liquor.Support.Models.Message
  alias Liquor.Filters.String, as: SF

  describe "apply_filter(&1, :match, &2, &3)" do
    test "can match a whole string" do
      a = insert(:message, body: "Hello, World")
      _b = insert(:message, body: "Goodbye, World")
      query =
        Message
        |> SF.apply_filter(:match, :body, "Hello, World")

      assert [m] = Repo.all(query)

      assert m.id == a.id
    end

    test "can match a string with a wildcard" do
      a = insert(:message, body: "Hello, World")
      _b = insert(:message, body: "Goodbye, World")
      query =
        Message
        |> SF.apply_filter(:match, :body, "Hello,*")

      assert [m] = Repo.all(query)

      assert m.id == a.id
    end

    test "can match a string with a wildcard character" do
      a = insert(:message, body: "Hello, World")
      b = insert(:message, body: "Cello, World")
      _c = insert(:message, body: "Goodbye, World")

      query =
        Message
        |> SF.apply_filter(:match, :body, "?ello, World")

      assert [x, y] = Repo.all(query)
      assert x.id in [a.id, b.id]
      assert y.id in [a.id, b.id]
    end

    test "can match a string with a literal *" do
      a = insert(:message, body: "Hello, *")
      _b = insert(:message, body: "Goodbye, World")
      query =
        Message
        |> SF.apply_filter(:match, :body, "Hello, \\*")

      assert [m] = Repo.all(query)
      assert m.id == a.id
    end
  end
end
