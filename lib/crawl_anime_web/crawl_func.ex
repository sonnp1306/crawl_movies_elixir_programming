defmodule CrawlAnimeWeb.CrawlFunc do
#  alias CrawlAnimeWeb.HttpClient

   @doc """
    Determined src by page_index and base_url
  """
  def determined_src(1 = _page_index, base_url), do: base_url

  def determined_src(page_index, base_url), do: base_url <> "page/#{page_index}/"

  def get_list_src_by_page_index(page_index, base_url) do
    response = HTTPoison.get!(determined_src(page_index, base_url))

    {:ok, html_document} = Floki.parse_document(response.body)
    html_document |> Floki.find(".last-film-box") |> Floki.find("a") |> Floki.attribute("href")
  end

    @doc """
  Lấy danh sách các url của phim từ trang đến trang
  """

  # temp = CrawlAnimeWeb.MovieController.caculate_res_link(1,20)
  # CrawlAnimeWeb.CrawlFunc1.get_movie_urls(temp, "https://ephimmoi.net/category/hoat-hinh/")
  def get_movie_urls({from, to,index_link, to_index_link}, url) do
    if index_link == to_index_link do
      list_item = get_list_src_by_page_index(index_link, url)
      |> List.flatten()

      page_size = to - from + 1
      from_index = determined_index(from,to_index_link)
      Enum.slice(list_item,from_index,page_size)

    else
      list_item = get_list_src_by_page_index(index_link, url)
      |> List.flatten()
      |> Enum.concat(
        get_list_src_by_page_index(to_index_link, url)
        |> List.flatten()
      )

      page_size = to - from + 1
      from_index = determined_index(from,to_index_link)
      Enum.slice(list_item,from_index,page_size)

    end
  end

  def determined_index(from, to_index) do
    if to_index >= 2 do
      temp = (to_index - 1)*32
      abs(temp - from)
    else
      from
    end
  end

  def parse_data(list_data) do
    list_data
    |> Enum.map(fn item -> HTTPoison.get!(item).body end)
    |> Enum.map(fn body ->
        {:ok, html} = Floki.parse_document(body)

        title = get_movie_title(html)
        thumnail = html |> Floki.find(".movie-info .movie-l-img img")|> Floki.attribute("src")|> List.last()
        year = html|> Floki.find("[rel=tag]")|> Floki.text()
        movie_director_name = html |> Floki.find("dd.movie-dd.dd-cat > .director") |> Floki.attribute("title") |> Enum.join(", ") |> Floki.text()
        movie_country = html |> Floki.find("dd.movie-dd.dd-cat >a")|> Floki.attribute("title")|> List.last()

        %{
          id: nil,
          title: title,
          movie_url: get_movie_link(html),
          thumnail_url: thumnail,
          year: year,
          number_of_episode: get_number_of_episode(html),
          full_series: get_full_series_status(html),
          director_name: movie_director_name,
          country: movie_country
        }
    end)
  end

  def get_movie_title(body) do
    body
    |> Floki.find(".movie-info .movie-title .title-1")
    |> Floki.text()
  end
  def get_full_series_status(body) do
    episode_list =
      body
      |> get_episode_list()

    if length(episode_list) > 1 do
      current_episode = List.first(episode_list)
      total_episode = Enum.at(episode_list, 1)
      current_episode == total_episode
    else
      false
    end
  end


  def get_episode_list(body) do
    body
    |> Floki.find(".movie-info .movie-meta-info .status")
    |> Floki.text()
    |> String.split([" ", ",", "/"])
    |> Enum.map(fn text ->
      case Integer.parse(text) do
        {value, _} -> value
        :error -> nil
      end
    end)
    |> Enum.filter(fn number -> number != nil end)
  end

  def get_movie_link(body) do
    data =
      body
      |> Floki.find("#film-content-wrapper>#film-content")
      |> Floki.attribute("data-href")

    case data do
      [head | _] -> head
      _ -> []
    end
  end

  def get_number_of_episode(body) do
    episode_list =
      body
      |> get_episode_list()

    if(length(episode_list) > 0) do
      List.first(episode_list)
    else
      nil
    end
  end

end
