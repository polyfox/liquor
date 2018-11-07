defmodule Liquor.Support.Repo.Migrations.AddEventDateToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :event_date, :date
    end
  end
end
