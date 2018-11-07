defmodule Liquor.Support.Models.Message do
  use Ecto.Schema

  schema "messages" do
    timestamps(type: :naive_datetime_usec)

    field :event_date, :date

    field :body, :string
    field :likes, :integer, default: 0
    field :rating, :decimal, default: Decimal.new(5)
  end
end
