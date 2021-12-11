defmodule DumboOctopusWeb.PageController do
  use DumboOctopusWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
