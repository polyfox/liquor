defmodule LiquorTest do
  use ExUnit.Case
  doctest Liquor

  test "greets the world" do
    assert Liquor.hello() == :world
  end
end
