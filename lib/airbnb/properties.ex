defmodule Airbnb.Properties do
  alias Airbnb.Property
  alias Airbnb.Repo

  def get_properties(), do: Repo.all(Property)

  def get_property(id), do: Repo.get(Property, id)

  def property_changeset(
    %Property{} = property \\ %Property{},
    params \\ %{}
  ) do
    Property.changeset(property, params)
  end

  def create_property(params) do
    %Property{}
    |> property_changeset(params)
    |> Repo.insert()
  end

  def update_property(id, params) do
    get_property(id)
    |> property_changeset(params)
    |> Repo.update()
  end

  def delete_property!(id) do
    Repo.get!(Property, id) |> Repo.delete!()
  end
end
