defmodule Liquor.Transformers.NaiveDateTimeTest do
  use ExUnit.Case
  alias Liquor.Transformers.NaiveDateTime, as: T

  describe "transform/1" do
    test "can transform a nil" do
      assert {:ok, nil} == T.transform(nil)
    end

    test "can transform a blank string" do
      assert {:ok, nil} == T.transform("")
    end

    test "can transform a year: prefix" do
      assert {:ok, {:year, 1999}} == T.transform("year:1999")
    end

    test "can transform a month: prefix" do
      assert {:ok, {:month, 12}} == T.transform("month:12")
    end

    test "can transform a day: prefix" do
      assert {:ok, {:day, 12}} == T.transform("day:12")
    end

    test "can transform a hour: prefix" do
      assert {:ok, {:hour, 12}} == T.transform("hour:12")
    end

    test "can transform a minute: prefix" do
      assert {:ok, {:minute, 12}} == T.transform("minute:12")
    end

    test "can transform a second: prefix" do
      assert {:ok, {:second, 12}} == T.transform("second:12")
    end

    test "can transform a microsecond: prefix" do
      assert {:ok, {:microsecond, 12}} == T.transform("microsecond:12")
    end

    test "can transform a NaiveDateTime struct" do
      assert {:ok,
        %NaiveDateTime{year: 2018, month: 11, day: 26, hour: 15, minute: 23, second: 5, microsecond: {0, 6}}
      } == T.transform(%NaiveDateTime{year: 2018, month: 11, day: 26, hour: 15, minute: 23, second: 5})
    end

    test "can transform a DateTime struct" do
      {:ok, dt, _} = DateTime.from_iso8601("2018-11-26T15:23:05Z")
      assert {:ok,
        %NaiveDateTime{year: 2018, month: 11, day: 26, hour: 15, minute: 23, second: 5, microsecond: {0, 6}}
      } == T.transform(dt)
    end
  end
end
