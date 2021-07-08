defmodule PhxCrawler.CrawlLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "crawl_logs" do
    field :crawl_at, :decimal
    field :status, :string
    field :total, :integer
    field :url, :string
    has_many :movies, PhxCrawler.Movie

    timestamps()
  end

  @doc false
  def changeset(crawl_log, attrs) do
    crawl_log
    |> cast(attrs, [:crawl_at, :url, :total, :status])
    |> validate_required([:crawl_at, :url, :total, :status])
  end
end
