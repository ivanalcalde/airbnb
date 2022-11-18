defmodule AirbnbWeb.PropertyController do
  use AirbnbWeb, :controller 

  alias Airbnb.Properties

  def index(conn, _params) do
    properties = Properties.get_properties()

    render(conn, "index.html", properties: properties)  
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: Properties.property_changeset())
  end

  def create(conn, %{"property" => property}) do
    case Properties.create_property(property) do
      {:ok, _property} ->
        conn
        |> put_flash(:info, "🏠 New property created")
        |> redirect(to: Routes.property_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    property = Properties.get_property(id)
    changeset = Properties.property_changeset(property)

    render(conn, "edit.html", changeset: changeset, property: property)
  end

  def update(conn, %{"id" => id, "property" => property}) do
    case Properties.update_property(id, property) do
      {:ok, _property} ->
        conn
        |> put_flash(:info, "🏠 Property updated")
        |> redirect(to: Routes.property_path(conn, :index))
      {:error, %{data: data} = changeset} -> 
        render(conn, "edit.html", changeset: changeset, property: data)
    end
  end

  def delete(conn, %{"id" => id}) do
    Properties.delete_property!(id)

    conn
    |> put_flash(:info, "🏠 Property removed")
    |> redirect(to: Routes.property_path(conn, :index))
  end
end
