defmodule Airbnb.Repo.Migrations.AddPropertiesTable do
  use Ecto.Migration

  def change do
    create table(:property) do
      add :number_of_bathrooms, :integer
      add :number_of_bedrooms, :integer
      add :number_of_beds, :integer
      add :number_of_travellers, :integer
      add :title, :string

      timestamps()
    end
  end
end
