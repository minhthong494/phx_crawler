defmodule PhxCrawlerWeb.HomeView do
  use PhxCrawlerWeb, :view

  def render("data.json", %{data: movies}) do
    %{data: render_one(movies, HomeView, "show.json")}
  end

  def render("show.json", %{user: user}) do
    %{name: user.name, address: user.address}
  end

  def render("movies.json", %{movies: movies}) do
    render_many(movies, PhxCrawlerWeb.CrawlLogView, "movie.json")
  end
end
