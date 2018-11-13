defmodule LiquorTest do
  use Liquor.Support.DataCase
  alias Liquor.Support.Models.Message

  @search_spec %{
    whitelist: %{
      "_" => true,
      "body" => :body,
      "event_date" => :event_date,
    },
    transform: %{
      _: {:type, :string},
      body: {:type, :string},
      event_date: {:type, :date},
    },
    filter: %{
      _: {:apply, LiquorTest, :keyword_filter, []},
      body: {:type, :string},
      event_date: {:type, :date},
    },
  }

  def keyword_filter(query, op, _key, value) do
    Liquor.Filter.apply_filter(query, op, :body, value, {:type, :string})
  end

  describe "prepare_terms/2" do
    test "prepares a search string" do
      assert {:ok, result} = Liquor.prepare_terms("body:'Hello, World' word", @search_spec)
      assert [
        {:match, :body, "Hello, World"},
        {:match, :_, "word"},
      ] == result
    end

    test "can whitelist terms with their prefixed operators" do
      assert {:ok, result} = Liquor.prepare_terms("==body:'Hello, World' >=event_date:2018-11-13 word", @search_spec)
      assert [
        {:==, :body, "Hello, World"},
        {:>=, :event_date, ~D[2018-11-13]},
        {:match, :_, "word"},
      ] == result
    end
  end

  describe "apply_search/3" do
    test "can parse a given phrase and search" do
      a = insert(:message, body: "Hello, World", event_date: %Date{year: 2018, month: 11, day: 7})
      _b = insert(:message, body: "Hello, World2", event_date: %Date{year: 2018, month: 11, day: 7})
      _c = insert(:message, body: "Goodbye, World", event_date: %Date{year: 2017, month: 11, day: 7})

      [m] =
        Message
        |> Liquor.apply_search("'Hello, World'", @search_spec)
        |> Repo.all()
      assert m.id == a.id
    end

    test "can parse a given search string" do
      a = insert(:message, body: "Hello, World", event_date: %Date{year: 2018, month: 11, day: 7})
      _b = insert(:message, body: "Hello, World2", event_date: %Date{year: 2018, month: 11, day: 7})
      _c = insert(:message, body: "Goodbye, World", event_date: %Date{year: 2017, month: 11, day: 7})

      [m] =
        Message
        |> Liquor.apply_search("body:'Hello, World'", @search_spec)
        |> Repo.all()
      assert m.id == a.id
    end

    test "can parse a given search string (negated)" do
      _a = insert(:message, body: "Hello, World", event_date: %Date{year: 2018, month: 11, day: 7})
      b = insert(:message, body: "Hello, World2", event_date: %Date{year: 2018, month: 11, day: 7})

      [m] =
        Message
        |> Liquor.apply_search("!body:'Hello, World'", @search_spec)
        |> Repo.all()
      assert m.id == b.id
    end

    test "can parse a given date string with year declaration" do
      a = insert(:message, body: "Hello, World", event_date: %Date{year: 2018, month: 11, day: 7})
      b = insert(:message, body: "Hello, World2", event_date: %Date{year: 2018, month: 11, day: 7})
      _c = insert(:message, body: "Goodbye, World", event_date: %Date{year: 2017, month: 11, day: 7})

      [x, y] =
        Message
        |> Liquor.apply_search("event_date:year:2018", @search_spec)
        |> Repo.all()
      assert x.id in [a.id, b.id]
      assert y.id in [a.id, b.id]
    end

    test "can parse a given date string with month declaration" do
      a = insert(:message, body: "Hello, World", event_date: %Date{year: 2018, month: 11, day: 7})
      b = insert(:message, body: "Hello, World2", event_date: %Date{year: 2018, month: 11, day: 7})
      _c = insert(:message, body: "Goodbye, World", event_date: %Date{year: 2018, month: 10, day: 7})

      [x, y] =
        Message
        |> Liquor.apply_search("event_date:month:11", @search_spec)
        |> Repo.all()
      assert x.id in [a.id, b.id]
      assert y.id in [a.id, b.id]
    end
  end
end
