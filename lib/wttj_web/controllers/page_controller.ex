defmodule WttjWeb.PageController do
  use WttjWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
