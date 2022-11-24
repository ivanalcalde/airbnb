defmodule Airbnb.Properties do
  import Ecto.Query, only: [from: 2]

  alias Airbnb.Property
  alias Airbnb.PropertyPhoto
  alias Airbnb.Repo

  def get_properties(), do: Repo.all(Property)

  def get_property!(id), do: Repo.get!(Property, id)

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

  def create_property_photos(property_id, urls) do
    property = get_property!(property_id)

    property_photos = Enum.map(urls, fn url ->
      Ecto.build_assoc(property, :property_photos, url: url)
      |> Map.take([:property_id, :url])
      |> Map.put(
        :inserted_at,
        NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      )
      |> Map.put(
        :updated_at,
        NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      )
    end)

    {count, _} = Repo.insert_all(PropertyPhoto, property_photos)

    {:ok, count}
  end

  def get_property_photos(property_id) do
    query = from p in PropertyPhoto,
      where: p.property_id == ^property_id

    Repo.all(query)
  end

  def update_property_photo(id, params) do
    photo = Repo.get!(PropertyPhoto, id)

    photo
    |> PropertyPhoto.changeset(params)
    |> Repo.update()
  end
end
