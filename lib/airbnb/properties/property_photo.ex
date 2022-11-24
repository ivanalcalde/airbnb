defmodule Airbnb.PropertyPhoto do
  use Ecto.Schema

  schema "property_photos" do
    field :url, :string
    field :title, :string
    belongs_to :property, Airbnb.Property

    timestamps()
  end

  def changeset(property_photo, params \\ %{}) do
    property_photo
    |> Ecto.Changeset.cast(params, [
      :url,
      :title,
    ])
    |> Ecto.Changeset.validate_required([
      :url
    ])
  end
end
