defmodule DumboOctopusWeb.Router do
  use DumboOctopusWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DumboOctopusWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DumboOctopusWeb do
    pipe_through :browser

    live "/", DumboOctopusLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", DumboOctopusWeb do
  #   pipe_through :api
  # end
end
