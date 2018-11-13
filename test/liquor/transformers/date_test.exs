defmodule Liquor.Transformers.DateTest do
  use ExUnit.Case
  alias Liquor.Transformers.Date, as: T

  describe "transform/1" do
    test "can transform a year: prefix" do
      assert {:ok, {:year, 1999}} == T.transform("year:1999")
    end

    test "can transform a month: prefix" do
      assert {:ok, {:month, 12}} == T.transform("month:12")
    end

    test "can transform a day: prefix" do
      assert {:ok, {:day, 12}} == T.transform("day:12")
    end
  end
end
