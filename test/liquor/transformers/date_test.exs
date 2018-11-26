defmodule Liquor.Transformers.DateTest do
  use ExUnit.Case
  alias Liquor.Transformers.Date, as: T

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

    test "can transform a date string" do
      assert {:ok, %Date{year: 2018, month: 11, day: 26}} == T.transform("2018-11-26")
    end

    test "can transform a Date struct" do
      assert {:ok, %Date{year: 2018, month: 11, day: 26}} == T.transform(%Date{year: 2018, month: 11, day: 26})
    end

    test "can transform a DateTime struct" do
      assert {:ok, %Date{year: 2018, month: 11, day: 26}} == T.transform(%NaiveDateTime{year: 2018, month: 11, day: 26, hour: 15, minute: 21, second: 45})
    end
  end
end
