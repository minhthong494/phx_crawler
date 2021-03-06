defmodule PhxCrawler.Movie do
  use Ecto.Schema
  import Ecto.Changeset

  schema "movies" do
    field :full_series, :boolean, default: false
    field :link, :string
    field :number_of_episode, :integer
    field :thumnail, :string
    field :title, :string
    field :year, :integer
    #field :crawl_log_id, :id
    belongs_to :crawl_log, PhxCrawler.CrawlLog
    many_to_many :directors, PhxCrawler.Director, join_through: "movies_directors"
    many_to_many :countries, PhxCrawler.Country, join_through: "movies_countries"

    field :directors_text, :string
    field :countries_text, :string
    timestamps()
  end

  @doc false
  def changeset(movie, attrs) do
    movie
    |> cast(attrs, [:title, :year, :thumnail, :number_of_episode, :link, :full_series])
    |> validate_required([:title, :year, :thumnail, :number_of_episode, :link, :full_series])
  end
end
