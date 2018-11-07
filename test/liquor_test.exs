defmodule LiquorTest do
  use Liquor.Support.DataCase
  alias Liquor.Support.Models.Message

  @search_spec %{
    whitelist: %{
      items: %{
        "body" => :body,
        "event_date" => :event_date,
      },
    },
    transform: %{
      items: %{
        body: {:type, :string},
        event_date: {:type, :date},
      },
      keyword: nil,
    },
    filter: %{
      nil: {:apply, LiquorTest, :keyword_filter, []},
      body: {:type, :string},
      event_date: {:type, :date},
    },
  }

  def keyword_filter(query, op, key, value) do
    Liquor.Filter.apply_filter(query, op, :body, value, {:type, :string})
  end

  describe "apply_search/3" do
    test "can parse a given search string" do
      a = insert(:message, body: "Hello, World", event_date: %Date{year: 2018, month: 11, day: 7})
      b = insert(:message, body: "Hello, World2", event_date: %Date{year: 2018, month: 11, day: 7})
      c = insert(:message, body: "Goodbye, World", event_date: %Date{year: 2017, month: 11, day: 7})

      [m] =
        Message
        |> Liquor.apply_search("body:'Hello, World'", @search_spec)
        |> Repo.all()
      assert m.id == a.id
    end

    test "can parse a given search string (negated)" do
      a = insert(:message, body: "Hello, World", event_date: %Date{year: 2018, month: 11, day: 7})
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
