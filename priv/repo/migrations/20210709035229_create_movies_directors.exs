defmodule PhxCrawler.Repo.Migrations.CreateMoviesDirectors do
  use Ecto.Migration

  def change do
    create table(:movies_directors) do
      add :movie_id, references(:movies, on_delete: :nothing)
      add :director_id, references(:directors, on_delete: :nothing)

      timestamps(default: fragment("NOW()"))
    end

    create unique_index(:movies_directors, [:movie_id, :director_id])
  end

  def down do
    drop table(:movies_directors)
  end
end
