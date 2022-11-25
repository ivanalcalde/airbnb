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

    {:ok, socket}
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
          Latitude: <%= text_input(f, :lat, placeholder: "lat") %>      
          <%= error_tag f, :lat %>
        </label>
        <label>
          Longitude: <%= text_input(f, :lng, placeholder: "lng") %>      
          <%= error_tag f, :lng %>
        </label>
        <%= submit "Save", class: "button" %>
      </.form>
      <div id="wrapper" phx-update="ignore">
        <div class="h-[650px]" id="map" phx-hook="Map">
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
      {:ok, property} -> assign(socket, :property, property)
      {:error, changeset} -> assign(socket, :changeset, changeset)
    end

    {:noreply, socket}
  end









end
