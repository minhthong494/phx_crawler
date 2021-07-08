defmodule PhxCrawlerWeb.CrawlLogView do
  use PhxCrawlerWeb, :view

  def render("crawllogs.json", %{crawl_logs: logs}) do
    render_many(logs, PhxCrawlerWeb.CrawlLogView, "crawllog.json")
  end

  def render("crawllog.json", %{crawl_log: log}) do
    %{
      crawl_at: log.crawl_at,
      url: log.url,
      total: log.total,
      status: log.status,
      id: log.id
    }
  end

  def render("movies.json", %{movies: movies}) do
    render_many(movies, PhxCrawlerWeb.CrawlLogView, "movie.json")
  end

  def render("movie.json", %{crawl_log: movie}) do
    %{
      id: movie.id,
      title: movie.title,
      thumnail: movie.thumnail,
      link: movie.link,
      year: movie.year,
      full_series: movie.full_series,
      number_of_episode: movie.number_of_episode
    }
  end
end
