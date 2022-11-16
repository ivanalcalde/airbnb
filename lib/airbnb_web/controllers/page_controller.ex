defmodule AirbnbWeb.PageController do
  use AirbnbWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
