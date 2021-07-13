defmodule PhxCrawler.Repo.Migrations.CreateDirectors do
  use Ecto.Migration

  def change do
    create table(:directors) do
      add :name, :string

      timestamps(default: fragment("NOW()"))
    end

    create unique_index(:directors, [:name])
  end

  def down do
    drop table(:directors)
  end
end
