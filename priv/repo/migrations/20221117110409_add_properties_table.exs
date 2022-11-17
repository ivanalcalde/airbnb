defmodule Airbnb.Repo.Migrations.AddPropertiesTable do
  use Ecto.Migration

  def change do
    create table(:property) do
      add :bathrooms, :integer
      add :bedrooms, :integer
      add :beds, :integer
      add :title, :string
      add :travellers, :integer
    end
  end
end
