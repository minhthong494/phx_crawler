defmodule PhxCrawlerWeb.Router do
  use PhxCrawlerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    #plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :introspect
  end
  @spec introspect(
          atom | %{:host => any, :method => any, :req_headers => any, optional(any) => any},
          any
        ) :: atom | %{:host => any, :method => any, :req_headers => any, optional(any) => any}
  def introspect(conn, _opts) do
    IO.puts """
    Introspect plugs
    Verb: #{inspect(conn.method)}
    Host: #{inspect(conn.host)}
    Headers: #{inspect(conn.req_headers)}
    """
    conn
  end

  pipeline :api do
    plug :accepts, ["json"]

  end

  scope "/", PhxCrawlerWeb do
    pipe_through :browser

    get "/", HomeController, :index
    post "/", HomeController, :request_crawl
    get "/export", HomeController, :export
    get "/history", CrawlLogController, :fetch
    get "/history/:id", CrawlLogController, :get_by_id
    post "/history", CrawlLogController, :retrieve
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhxCrawlerWeb do
  #   pipe_through :api
  # end

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
      live_dashboard "/dashboard", metrics: PhxCrawlerWeb.Telemetry
    end
  end
end
