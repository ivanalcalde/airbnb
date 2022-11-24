defmodule Airbnb.Property do
  use Ecto.Schema

  schema "properties" do
    field :number_of_bathrooms, :integer
    field :number_of_bedrooms, :integer
    field :number_of_beds, :integer
    field :number_of_travellers, :integer
    field :title, :string
    has_many :property_photos, Airbnb.PropertyPhoto

    timestamps()
  end

  def changeset(property, params \\ %{}) do
    property
    |> Ecto.Changeset.cast(params, [
      :number_of_bathrooms,
      :number_of_bedrooms,
      :number_of_beds,
      :number_of_travellers,
      :title,
    ])
    |> Ecto.Changeset.validate_required([
      :title
    ])
  end
end
