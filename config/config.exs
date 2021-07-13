# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :phx_crawler,
  ecto_repos: [PhxCrawler.Repo]

# Configures the endpoint
config :phx_crawler, PhxCrawlerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2BYsxt3R6JGYQIzbAIijt12NAXLuuW21DDndhF2NvgkRzUGQZykbiArtqJgxzTzh",
  render_errors: [view: PhxCrawlerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PhxCrawler.PubSub,
  live_view: [signing_salt: "faNudEwN"]

config :cors_plug,
[
  origin: "*",
  credentials: true,
  max_age: 1_728_000,
  headers: [
    "Authorization",
    "Content-Type",
    "Accept",
    "Origin",
    "User-Agent",
    "DNT",
    "Cache-Control",
    "X-Mx-ReqToken",
    "Keep-Alive",
    "X-Requested-With",
    "If-Modified-Since",
    "X-CSRF-Token"
  ],
  expose: ["x-total-items"],
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  send_preflight_response?: true
]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
