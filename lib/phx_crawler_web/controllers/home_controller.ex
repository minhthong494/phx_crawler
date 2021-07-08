defmodule PhxCrawlerWeb.HomeController do
  use PhxCrawlerWeb, :controller

  def index(conn, _params) do
    render(conn, "home.html", movies: [])
  end

  plug PhxCrawlerWeb.Plugs.Locale, "en" when action in [:test]

  def test(conn, params) do
    IO.inspect(conn)
    IO.inspect(params)

    json(conn, %{
      status: "OK",
      message: "Success",
      data: []
    })
  end

  def export(conn, params) do
    IO.inspect(conn)
    IO.inspect(params)
    result = SimpleCrawler.crawl_from_url(1, "https://phimmoii.org/the-loai/hoat-hinh.html")
    cvt_result = %{result | movies: Enum.map(result.movies, fn mv -> Map.from_struct(mv) end)}

    result_cs =
      PhxCrawler.CrawlLog.changeset(%PhxCrawler.CrawlLog{}, cvt_result)
      |> Ecto.Changeset.cast_assoc(:movies, with: &PhxCrawler.Movie.changeset/2)

    IO.inspect(result_cs)

    case PhxCrawler.Repo.insert(result_cs) do
      {:ok, changeset} ->
        IO.puts("OK")
        IO.inspect(changeset)

      {:error, changeset} ->
        IO.puts("Error")
        IO.inspect(changeset)
    end
  end

  # @base_url  "https://phimmoii.org/the-loai/hoat-hinh/"
  def crawl_by_url(conn, params) do
    IO.inspect(params)

    case params do
      %{"form_data" => %{"url" => url}} ->
        data = SimpleCrawler.crawl_from_url(1, String.trim_trailing(url, ".html") <> "/")

        case persist(data) do
          {:ok, _} -> json(conn, %{message: "success"})
          {:error, _} -> json(conn, %{message: "Intenal error"})
        end

      %{"file" => %Plug.Upload{filename: _filename, path: path}} ->
        case File.read(path) do
          {:ok, lines} ->
            IO.inspect(lines)

            list_data =
              lines
              |> String.trim_trailing("\n")
              |> String.split("\n")
              |> (fn links ->
                    for link <- links do
                      task =
                        Task.async(SimpleCrawler, :crawl_from_url, [
                          1,
                          String.trim_trailing(link, ".html") <> "/"
                        ])

                      IO.puts("starting crawling #{link}")
                      data = Task.await(task, 30000)
                      data
                    end
                  end).()

            status =
              Enum.all?(list_data, fn data ->
                case persist(data) do
                  {:ok, _} -> true
                  {:error, _} -> false
                end
              end)

            if status == true do
              json(conn, %{message: "success"})
            else
              json(conn, %{message: "Intenal error"})
            end

          {:error, reason} ->
            IO.puts(reason)
        end
    end
  end

  def persist(result) do
    cvt_result = %{result | movies: Enum.map(result.movies, fn mv -> Map.from_struct(mv) end)}

    result_cs =
      PhxCrawler.CrawlLog.changeset(%PhxCrawler.CrawlLog{}, cvt_result)
      |> Ecto.Changeset.cast_assoc(:movies, with: &PhxCrawler.Movie.changeset/2)

    case PhxCrawler.Repo.insert(result_cs) do
      {:ok, changeset} -> {:ok, changeset}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
