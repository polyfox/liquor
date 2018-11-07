defmodule Liquor.Support.Repo.Migrations.AddMessagesTable do
  use Ecto.Migration

  def change do
    create table(:messages) do
      timestamps(type: :naive_datetime_usec)

      add :body, :text, null: false
      add :likes, :integer, null: false
      add :rating, :decimal, null: false
    end
  end
end
