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

  @num_pages 10
  def crawl_job(url) do
    data = SimpleCrawler.crawl_from_url(@num_pages, url)
    case persist(data) do
      {:ok, _} -> IO.puts("Persist data successfully")
      {:error} -> IO.puts("Error when persist data")
    end
  end

  def request_crawl(conn, params) do
    IO.inspect(params)

    case params do
      %{"form_data" => %{"url" => url}} ->
        Task.start(PhxCrawlerWeb.HomeController, :crawl_job, [url])
        json(conn, %{ok: "Crawler started"})

      %{"file" => %Plug.Upload{filename: _filename, path: path}} ->
        case File.read(path) do
          {:ok, lines} ->

              lines
              |> String.trim_trailing("\n")
              |> String.split("\n")
              |> Enum.map(fn link -> Task.start(PhxCrawlerWeb.HomeController, :crawl_job, [link]) end)
              json(conn, %{ok: "Crawler started"})
          _ ->
            json(conn |> put_status(400), %{error: "Readfile error"})
        end
    end
  end

  # @base_url  "https://phimmoii.org/the-loai/hoat-hinh/"
  def crawl_by_url(conn, params) do
    IO.inspect(params)

    case params do
      %{"form_data" => %{"url" => url}} ->
        data = SimpleCrawler.crawl_from_url(1, url)

        case persist(data) do
          {:ok, _cs} -> json(conn, %{message: "success"})
          _ -> json(conn, %{message: "Intenal error"})
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
                          link
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

    IO.puts("----------- INSERT DIRECTORS ---------- ")
    Enum.map(cvt_result.movies, fn movie -> movie.directors end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.map(fn director ->
      %PhxCrawler.Director{name: director}
      |> PhxCrawler.Repo.insert(on_conflict: :nothing)
    end)

    listDirectors = PhxCrawler.Repo.all(PhxCrawler.Director)

    movies_with_directors =
      cvt_result.movies
      |> Enum.map(fn movie ->
        movie_directors =
          Enum.map(movie.directors, fn director_name ->
            Enum.find(listDirectors, fn director -> director.name == director_name end)
          end)

        {movie.title, movie.link, movie_directors}
      end)

    IO.puts("----------- INSERT COUNTRIES ---------- ")
    Enum.map(cvt_result.movies, fn movie -> movie.countries end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.map(fn country ->
      %PhxCrawler.Country{name: country}
      |> PhxCrawler.Repo.insert(on_conflict: :nothing)
    end)

    listCountries = PhxCrawler.Repo.all(PhxCrawler.Country)

    movies_with_countries =
      cvt_result.movies
      |> Enum.map(fn movie ->
        movie_countries =
          Enum.map(movie.countries, fn country_name ->
            Enum.find(listCountries, fn country -> country.name == country_name end)
          end)

        {movie.title, movie.link, movie_countries}
      end)

    IO.puts("----------- INSERT CRAWL_LOG && MOVIES ---------- ")
    result_cs =
      PhxCrawler.CrawlLog.changeset(%PhxCrawler.CrawlLog{}, cvt_result)
      |> Ecto.Changeset.cast_assoc(:movies, with: &PhxCrawler.Movie.changeset/2)

    {:ok, crawl_log} = PhxCrawler.Repo.insert(result_cs)

    IO.puts("----------- INSERT MANY-MANY RELATIONSHIP ---------- ")
    crawl_log.movies
    |> Enum.map(fn movie ->
      {_, _, directors} =
        Enum.find(movies_with_directors, fn {title, link, _} ->
          title == movie.title && link == movie.link
        end)

      Ecto.Changeset.change(movie |> PhxCrawler.Repo.preload(:directors))
      |> Ecto.Changeset.put_assoc(:directors, directors)
      |> PhxCrawler.Repo.update(on_conflict: :nothing)

      {_, _, countries} =
        Enum.find(movies_with_countries, fn {title, link, _} ->
          title == movie.title && link == movie.link
        end)

      Ecto.Changeset.change(movie |> PhxCrawler.Repo.preload(:countries))
      |> Ecto.Changeset.put_assoc(:countries, countries)
      |> PhxCrawler.Repo.update(on_conflict: :nothing)
    end)

    {:ok, result_cs}
  end
end
