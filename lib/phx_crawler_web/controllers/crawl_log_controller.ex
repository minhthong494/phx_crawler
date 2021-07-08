defmodule PhxCrawlerWeb.CrawlLogController do
  use PhxCrawlerWeb, :controller
  alias PhxCrawler.Repo
  import Ecto.Query, only: [from: 2, limit: 2, offset: 2]

  @limit 10
  @offset 0
  def retrieve(conn, %{"url" => url, "time" => time} = params) do
    IO.inspect(conn)
    IO.inspect(params)

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

    case PhxCrawler.Repo.all(query) do
      {:ok, cs} -> json(conn, %{})
    end
  end

  @limit 10
  @offset 0
  def get_by_id(conn, %{"id" => id} = params) do
    limit = params["limit"] || @limit
    offset = params["offset"] || @offset

    query =
      from mv in PhxCrawler.Movie,
        where: mv.crawl_log_id == ^id

        IO.inspect(params)
        IO.inspect(query)
    query = Enum.reduce(params, query, fn
      {"year", year}, qr -> xx = from a in qr, where: a.year == ^year
                              IO.puts("hello ")
                              IO.inspect(xx)
                              xx
      {"is_complete", is_complete}, qr -> from a in qr, where: a.full_series == ^is_complete
      _, qr ->  IO.puts("unmatched")
                # IO.inspect(x)
                qr
    end)
    IO.inspect(query)
    total = PhxCrawler.Repo.aggregate(query, :count)
    data =
      PhxCrawler.Repo.all(from mv in query,
        limit: ^limit,
        offset: ^offset
      )

    render(conn |> Plug.Conn.put_resp_header("x-total-items", Integer.to_string(total)), "movies.json",
        movies: data
      )
  end

  @limit 10
  @offset 0
  def fetch(conn, params) do
    limit = params["limit"] || @limit
    offset = params["offset"] || @offset

    total = PhxCrawler.Repo.aggregate(PhxCrawler.CrawlLog, :count)
    data = PhxCrawler.Repo.all(PhxCrawler.CrawlLog |> limit(^limit) |> offset(^offset))

    render(conn |> Plug.Conn.put_resp_header("x-total-items", Integer.to_string(total)), "crawllogs.json", crawl_logs: data)
  end
end
