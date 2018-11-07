defmodule Liquor.Support.Factory do
  use ExMachina.Ecto, repo: Liquor.Support.Repo

  def message_factory do
    %Liquor.Support.Models.Message{
      body: "Hello, World",
      likes: 1,
      rating: Decimal.new(5),
    }
  end
end
