defmodule CrawlAnimeWeb.CrawlFunc1 do

  def determined_src(num) do
    if num > 1 do
      "https://ephimmoi.net/category/hoat-hinh/page/#{num}/"
    else
      "https://ephimmoi.net/category/hoat-hinh/"
    end
  end

  def get_list_src(num) do
    Enum.map(1..num, fn x -> determined_src(x) end)
  end

  def crawlOneUrl(src) do
    # parse reponse

    reponse = HTTPoison.get!(src)
    {:ok, html} = Floki.parse_document(reponse.body)
    # map = %{ title: nil, link: nil, full_series: nil, number_of_episode: nil, thumnail: nil, year: nil}

    # get list attribute
    list_title = html |> Floki.find(".last-film-box") |> Floki.find("a") |> Floki.attribute("title")
    list_href = html |> Floki.find(".last-film-box") |> Floki.find("a") |> Floki.attribute("href")
    list_number_of_episode = html |> Floki.find("div.movie-meta") |> Floki.find(".ribbon")
    list_thumnail = html |> Floki.find(".movie-thumbnail.ratio-box.ratio-3_4") |> Floki.find("[data-bg]") |> Floki.attribute("data-bg")

    for n <- 0..length(list_title)-1, do:
      %{
        title: Enum.at(list_title, n),
        link:  Enum.at(list_href,n),
        full_series: true,
        number_of_episode: Enum.at(list_number_of_episode, n) |> elem(2) |> List.first,
        thumnail: Enum.at(list_thumnail,n),
        # year: Regex.run(~r/\({1}+[0-9]{4}+\)/, Enum.at(list_title, n)) |> List.first,
      }

      # %{ crawled_at: DateTime.utc_now, total: length(item), items: item}
    end

    def crawl_link(src) do
      reponse = HTTPoison.get!(src)
      {:ok, html} = Floki.parse_document(reponse.body)
      html |> Floki.find(".last-film-box") |> Floki.find("a") |> Floki.attribute("href")
    end

    def crawl_page_link({from,to,page}) do
      list_src = get_list_src(page)
      item = for n <- 0..length(list_src)-1, do: crawl_link(Enum.at(list_src,n))
      List.flatten(item)
      |> Enum.slice(from,to - from + 1)
    end


end
