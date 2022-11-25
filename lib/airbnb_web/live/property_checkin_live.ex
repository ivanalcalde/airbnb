defmodule AirbnbWeb.PropertyCheckinLive do
  use AirbnbWeb, :live_view

  alias Airbnb.Properties

  def mount(_params, _session, socket) do
    if connected?(socket), do: Properties.subscribe_properties()

    socket = assign(socket, :properties, Properties.get_properties())

    {:ok, socket, temporary_assigns: [properties: []]}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col space-y-4">
      <h1 class="text-4xl mb-4">Properties Check-In/Out</h1>
      <AirbnbWeb.Components.features items={[
        "LiveView",
        "A LiveView spawns one process per client and uses web-sockets",
        "Real time updates with PubSub"
      ]} />
      <div
        id="properties"
        phx-update="prepend"
        class="flex flex-col space-y-4"
      >
        <div
          :for={property <- @properties}
          id={"property-#{property.id}"}
          class={"flex items-center justify-between p-8 border-2 border-dashed rounded-lg #{if property.checked_in?, do: "bg-red-100 border-red-200", else: "bg-green-100 border-green-200"}"}
        >
          <div><%= property.title %></div>
          <a
            class={if property.checked_in?, do: "button-red", else: "button"}
            href="#"
            phx-click="toggle_checkin"
            phx-value-id={property.id}
            phx-disable-with="Saving..."
          >
            <%= if property.checked_in?, do: "Check Out", else: "Check In" %>
          </a>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("toggle_checkin", %{"id" => id}, socket) do
    {:ok, _property} = Properties.update_property_toggle_checkin(id)

    {:noreply, socket}
  end

  def handle_info({:property_updated, property}, socket) do
    socket =
      update(
        socket,
        :properties,
        fn properties -> [property | properties] end
      )

    {:noreply, socket}
  end
end
