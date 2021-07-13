defmodule PhxCrawler.MoviesCountries do
  use Ecto.Schema
  import Ecto.Changeset

  schema "movies_countries" do
    field :movie_id, :id
    field :country_id, :id

    timestamps()
  end

  @doc false
  def changeset(movies_countries, attrs) do
    movies_countries
    |> cast(attrs, [])
    |> validate_required([])
  end
end
