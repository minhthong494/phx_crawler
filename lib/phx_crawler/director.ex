defmodule PhxCrawler.Director do
  use Ecto.Schema
  import Ecto.Changeset

  schema "directors" do
    field :name, :string, on_conflict: :nothing
    many_to_many :movies, PhxCrawler.Movie, join_through: "movies_directors"
    timestamps()
  end

  @doc false
  def changeset(director, attrs) do
    director
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
