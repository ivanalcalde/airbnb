defmodule Airbnb.Repo.Migrations.AddLocationToProperties do
  use Ecto.Migration

  def change do
    alter table(:properties) do
      add :lat, :float
      add :lng, :float
    end
  end
end
