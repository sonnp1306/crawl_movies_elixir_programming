defmodule CrawlAnime.Repo do
  use Ecto.Repo,
    otp_app: :crawl_anime,
    adapter: Ecto.Adapters.Postgres
end
