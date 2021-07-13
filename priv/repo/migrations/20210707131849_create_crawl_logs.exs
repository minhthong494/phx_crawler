defmodule PhxCrawler.Repo.Migrations.CreateCrawlLogs do
  use Ecto.Migration

  def change do
    create table(:crawl_logs) do
      add :crawl_at, :decimal
      add :url, :string
      add :total, :integer
      add :status, :string

      timestamps()
    end

  end

  def down do
    drop table(:crawl_logs)
  end
end
