defmodule PhxCrawlerWeb.CrawlLogController do
  use PhxCrawlerWeb, :controller
  alias PhxCrawler.Repo
  import Ecto.Query

  @limit 10
  @offset 0
  def retrieve(conn, %{"url" => url, "time" => time} = params) do
    limit = params["limit"] || @limit
    offset = params["offset"] || @offset
    IO.puts("query params #{url} #{time} #{limit} #{offset} #{is_integer(limit)}")

    query =
      from(mv in PhxCrawler.Movie,
        join: l in assoc(mv, :crawl_log),
        where:
          l.url == "https://phimmoii.org/the-loai/hoat-hinh.html" and l.crawl_at == 1_625_698_590,
        limit: 10,
        offset: 30
      )

    case Repo.all(query) do
      {:ok, _} -> json(conn, %{})
    end
  end

  @limit 10
  @offset 0
  def get_by_id(conn, %{"id" => id} = params) do
    limit = params["limit"] || @limit
    offset = params["offset"] || @offset

    query =
      PhxCrawler.Movie
      |> where([mv], mv.crawl_log_id == ^id)
      |> join_and_filter_directors(params["director_id"])
      |> join_and_filter_countries(params["country_id"])
      |> group_by([mv], mv.id)

    query =
      Enum.reduce(params, query, fn
        {"year", year}, qr ->
          from a in qr, where: a.year == ^year

        {"is_complete", is_complete}, qr ->
          from a in qr, where: a.full_series == ^is_complete

        _, qr ->
          qr
      end)

    IO.inspect(query)
    total = PhxCrawler.Repo.aggregate(from(u in subquery(query)), :count)

    IO.puts("---------------")
    data =
      PhxCrawler.Repo.all(
        from mv in query,
          limit: ^limit,
          offset: ^offset
      )
      |> PhxCrawler.Repo.preload(:directors)
      |> PhxCrawler.Repo.preload(:countries)

    render(
      conn |> Plug.Conn.put_resp_header("x-total-items", Integer.to_string(total)),
      "movies.json",
      movies: data
    )
  end

  defp join_and_filter_directors(query, nil) do
    from mv in query,
    left_join: d in assoc(mv, :directors)
  end

  defp join_and_filter_directors(query, id) do
    from mv in query,
    left_join: d in assoc(mv, :directors),
    where: d.id == ^id
  end

  defp join_and_filter_countries(query, nil) do
    from mv in query,
    left_join: c in assoc(mv, :countries)
  end

  defp join_and_filter_countries(query, id) do
    from mv in query,
    left_join: c in assoc(mv, :countries),
    where: c.id == ^id
  end

  @limit 10
  @offset 0
  def fetch(conn, params) do
    limit = params["limit"] || @limit
    offset = params["offset"] || @offset

    total = PhxCrawler.Repo.aggregate(PhxCrawler.CrawlLog, :count)

    data =
      PhxCrawler.Repo.all(
        PhxCrawler.CrawlLog
        |> limit(^limit)
        |> offset(^offset)
        |> order_by([l], desc: l.crawl_at)
      )

    render(
      conn |> Plug.Conn.put_resp_header("x-total-items", Integer.to_string(total)),
      "crawllogs.json",
      crawl_logs: data
    )
  end
end
