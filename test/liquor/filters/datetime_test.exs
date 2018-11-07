defmodule Liquor.Filters.DateTimeTest do
  use Liquor.Support.DataCase
  alias Liquor.Support.Models.Message
  alias Liquor.Filters.DateTime, as: DTF

  describe "apply_filter(&1, :match, &2, %Date{})" do
    test "can filter by date" do
      a = insert(:message, inserted_at: %NaiveDateTime{year: 2018, month: 11, day: 7, hour: 0, minute: 0, second: 0})
      _b = insert(:message, inserted_at: %NaiveDateTime{year: 2018, month: 11, day: 6, hour: 0, minute: 0, second: 0})
      query =
        Message
        |> DTF.apply_filter(:match, :inserted_at, %Date{year: 2018, month: 11, day: 7})
      assert [m] = Repo.all(query)
      assert m.id == a.id
    end
  end

  describe "apply_filter(&1, :match, &2, %NaiveDateTime{})" do
    test "can match datetime with a NaiveDateTime" do
      a = insert(:message, inserted_at: %NaiveDateTime{year: 2018, month: 11, day: 7, hour: 0, minute: 0, second: 0})
      _b = insert(:message, inserted_at: %NaiveDateTime{year: 2018, month: 11, day: 6, hour: 0, minute: 0, second: 0})
      query =
        Message
        |> DTF.apply_filter(:match, :inserted_at, %NaiveDateTime{year: 2018, month: 11, day: 7, hour: 0, minute: 0, second: 0})
      assert [m] = Repo.all(query)
      assert m.id == a.id
    end
  end

  describe "apply_filter(&1, :match, &2, {:year, year})" do
    test "can filter by year" do
      a = insert(:message, event_date: %Date{year: 2018, month: 11, day: 7})
      _b = insert(:message, event_date: %Date{year: 2017, month: 11, day: 7})
      query =
        Message
        |> DTF.apply_filter(:match, :event_date, {:year, 2018})
      assert [m] = Repo.all(query)
      assert m.id == a.id
    end
  end

  describe "apply_filter(&1, :match, &2, {:month, month})" do
    test "can filter by month" do
      a = insert(:message, event_date: %Date{year: 2018, month: 11, day: 7})
      b = insert(:message, event_date: %Date{year: 2017, month: 11, day: 7})
      _c = insert(:message, event_date: %Date{year: 2017, month: 12, day: 7})
      query =
        Message
        |> DTF.apply_filter(:match, :event_date, {:month, 11})
      assert [x, y] = Repo.all(query)
      assert x.id in [a.id, b.id]
      assert y.id in [a.id, b.id]
    end
  end

  describe "apply_filter(&1, :match, &2, {:day, day})" do
    test "can filter by day" do
      a = insert(:message, event_date: %Date{year: 2018, month: 11, day: 6})
      b = insert(:message, event_date: %Date{year: 2017, month: 11, day: 6})
      _c = insert(:message, event_date: %Date{year: 2017, month: 12, day: 7})
      query =
        Message
        |> DTF.apply_filter(:match, :event_date, {:day, 6})
      assert [x, y] = Repo.all(query)
      assert x.id in [a.id, b.id]
      assert y.id in [a.id, b.id]
    end
  end
end
