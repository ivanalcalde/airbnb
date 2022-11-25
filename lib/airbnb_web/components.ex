defmodule AirbnbWeb.Components do
  use Phoenix.Component

  attr :items, :list, default: []

  def features(assigns) do
    ~H"""
    <ul class="list-none space-y-1 rounded-lg p-1 border-dashed border-2 border-gray-100">
      <li
        :for={item <- @items}
        class="px-4 py-2 rounded-lg text-lg"
      >
        <%= "✅ #{item}" %>
      </li>
    </ul>
    """
  end
end
