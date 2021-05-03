defmodule WttjWeb.Router do
  use WttjWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WttjWeb do
    pipe_through :browser

    # get "/", PageController, :index
    get "/", Plugs.Redirector, [location: "/app/job-statistics"], as: :root
  end

  scope "/app", WttjWeb do
    pipe_through :browser

    resources "/categories", CategoryController, param: "name"

    get "/professions/import", ProfessionController, :import
    post "/professions/import", ProfessionController, :save_import
    resources "/professions", ProfessionController

    get "/jobs/finder", JobController, :finder
    get "/jobs/import", JobController, :import
    post "/jobs/import", JobController, :save_import
    resources "/jobs", JobController

    get "/countries/import", CountryController, :import
    post "/countries/import", CountryController, :save_import
    resources "/countries", CountryController

    get "/job-statistics", JobStatisticController, :index
  end

  scope "/api", WttjWeb do
    pipe_through :api

    resources "/jobs", JobApiController, only: [:index, :show]
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: WttjWeb.Telemetry
    end
  end
end
