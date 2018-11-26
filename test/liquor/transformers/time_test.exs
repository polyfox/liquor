defmodule Liquor.Transformers.TimeTest do
  use ExUnit.Case
  alias Liquor.Transformers.Time, as: T

  describe "transform/1" do
    test "can transform a nil" do
      assert {:ok, nil} == T.transform(nil)
    end

    test "can transform a blank string" do
      assert {:ok, nil} == T.transform("")
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
  end
end
