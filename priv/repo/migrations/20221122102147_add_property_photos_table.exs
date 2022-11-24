defmodule Airbnb.Repo.Migrations.AddPropertyPhotosTable do
  use Ecto.Migration

  def change do
    create table(:property_photos) do
      add :property_id, references(:properties)
      add :url, :string
      add :title, :string

      timestamps()
    end
  end
end
