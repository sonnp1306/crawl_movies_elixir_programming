defmodule CrawlAnimeWeb.PageController do
  use CrawlAnimeWeb, :controller
  alias CrawlAnimeWeb.CrawlFunc

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def crawlAllData(conn, _params) do
    item = CrawlFunc.crawlAllData |> List.flatten
    # map = %{ title: nil, link: nil, full_series: nil, number_of_episode: nil, thumnail: nil, year: nil}

    # map = %{ crawled_at: DateTime.utc_now, total: length(item), items: item}
    # changeset = Anime.changeset
    render(conn, "show_all_data.html", listData: item)
  end
end
