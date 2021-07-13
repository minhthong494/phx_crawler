defmodule PhxCrawler.MoviesDirectors do
  use Ecto.Schema
  import Ecto.Changeset

  schema "movies_directors" do
    field :movie_id, :id
    field :director_id, :id

    timestamps()
  end

  @doc false
  def changeset(movies_directors, attrs) do
    movies_directors
    |> cast(attrs, [])
    |> validate_required([])
  end
end
