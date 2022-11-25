defmodule Airbnb.Repo.Migrations.AddCheckinToProperties do
  use Ecto.Migration

  def change do
    alter table(:properties) do
      add :checked_in?, :boolean
    end
  end
end
