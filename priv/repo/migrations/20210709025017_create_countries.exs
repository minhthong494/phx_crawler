defmodule PhxCrawler.Repo.Migrations.CreateCountries do
  use Ecto.Migration

  def change do
    create table(:countries) do
      add :name, :string

      timestamps()
    end

    create unique_index(:countries, [:name])
  end

  def down do
    drop table(:countries)
  end
end
