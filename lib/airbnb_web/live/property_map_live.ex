defmodule AirbnbWeb.PropertyMapLive do
  use AirbnbWeb, :live_view
  
  alias Airbnb.Properties

  def mount(%{"id" => id}, _session, socket) do
    property = Properties.get_property!(id)
    changeset = Properties.property_changeset(property)

    socket = assign(socket,
      changeset: changeset,
      property_id: id,
      property: property
    )

    property_location? = Map.get(property, :lat) && Map.get(property, :lng)

    if connected?(socket) && property_location? do
      {:ok, socket |> update_location_event()}
    else
      {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <h1 class="text-4xl"><%= @property.title %> [Location]</h1>
      <.form
        class="px-4 py-8 flex space-x-4 border-dashed border-2 rounded-lg"
        let={f}
        for={@changeset}
        phx-change="validate"
        phx-submit="save"
      >
        <label>
          Latitude: <%= text_input(f, :lat, placeholder: "lat", readonly: true, class: "readonly") %>      
          <%= error_tag f, :lat %>
        </label>
        <label>
          Longitude: <%= text_input(f, :lng, placeholder: "lng", readonly: true, class: "readonly") %>      
          <%= error_tag f, :lng %>
        </label>
        <%= submit "Save",
          disabled: !lat_lng_changed(@changeset),
          class: "button"
        %>
      </.form>
      <div id="wrapper" phx-update="ignore">
        <div
          class="h-[650px]"
          id="map"
          phx-hook="AdminPropertyMap"
          data-mapcenter={Jason.encode!(%{
            lat: @property.lat || 42.30,
            lng: @property.lng || -1.97
          })}
        >
        </div>
      </div>
    </div>
    """
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end
  
  def handle_event(
    "save",
    %{"property" => %{"lat" => lat, "lng" => lng}},
    socket
  ) do
    socket = case Properties.update_property(socket.assigns.property.id, %{lat: lat, lng: lng}) do
      {:ok, property} -> 
        assign(socket, :property, property)
        |> update_location_event()
      {:error, changeset} -> assign(socket, :changeset, changeset)
    end

    {:noreply, socket}
  end

  def handle_event("set_coordinates", %{"lat" => lat, "lng" => lng}, socket) do
    changeset = Properties.property_changeset(
      socket.assigns.changeset.data,
      %{lat: lat, lng: lng}
    )

    {:noreply, assign(socket, :changeset, changeset)}
  end

  defp update_location_event(socket) do
    location = %{
      id: socket.assigns.property.id,
      description: socket.assigns.property.title,
      lat: socket.assigns.property.lat,
      lng: socket.assigns.property.lng
    }

    push_event(socket, "update_location", location)
  end

  defp lat_lng_changed(changeset) do
    changes_keys = Map.keys(changeset.changes)

    :lat in changes_keys or :lng in changes_keys    
  end
end
