defmodule PhxCrawlerWeb.PageController do
  use PhxCrawlerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
