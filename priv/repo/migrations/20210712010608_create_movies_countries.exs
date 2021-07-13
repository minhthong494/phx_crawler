defmodule PhxCrawler.Repo.Migrations.CreateMoviesCountries do
  use Ecto.Migration

  def change do
    create table(:movies_countries) do
      add :movie_id, references(:movies, on_delete: :nothing)
      add :country_id, references(:countries, on_delete: :nothing)

      timestamps(default: fragment("NOW()"))
    end

    create unique_index(:movies_countries, [:movie_id, :country_id])
  end
end
