defmodule PhxCrawler.Repo do
  use Ecto.Repo,
    otp_app: :phx_crawler,
    adapter: Ecto.Adapters.Postgres
end
