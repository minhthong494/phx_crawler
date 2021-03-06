defmodule PhxCrawler.Repo.Migrations.CreateMovies do
  use Ecto.Migration

  def change do
    create table(:movies) do
      add :title, :string
      add :year, :integer
      add :thumnail, :string
      add :number_of_episode, :integer
      add :link, :string
      add :full_series, :boolean, default: false, null: false
      add :crawl_log_id, references(:crawl_logs, on_delete: :nothing)
      add :directors_text, :string
      add :countries_text, :string

      timestamps()
    end

    create index(:movies, [:crawl_log_id])
  end

  def down do
    drop table(:movies)
  end
end
