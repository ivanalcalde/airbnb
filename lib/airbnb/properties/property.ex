defmodule Airbnb.Property do
  use Ecto.Schema

  schema "property" do
    field :bathrooms, :integer
    field :bedrooms, :integer
    field :beds, :integer
    field :title, :string
    field :travellers, :integer
  end

  def changeset(property, params \\ %{}) do
    property
    |> Ecto.Changeset.cast(params, [
      :bathrooms,
      :bedrooms,
      :beds,
      :title,
      :travellers
    ])
    |> Ecto.Changeset.validate_required([
      :title
    ])
  end
end
