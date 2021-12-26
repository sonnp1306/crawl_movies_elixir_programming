defmodule CrawlAnimeWeb.CrawlFunc1 do
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
  def get_movie_urls({from, to}, url) do
    if from == to do
      get_list_src_by_page_index(from, url)
      |> List.flatten()
      # response = HTTPoison.get!(determined_src(from, url))

      # {:ok, html_document} = Floki.parse_document(response.body)
      # html_document |> Floki.find(".last-film-box") |> Floki.find("a") |> Floki.attribute("href") |> List.flatten()
      # |> Enum.slice(floor(index_at/from),floor(index_end/to))
    else
      get_list_src_by_page_index(from, url)
      |> List.flatten()
      |> Enum.concat(
        get_list_src_by_page_index(to, url)
        |> List.flatten()
      )
    end
  end


  # list_data = CrawlAnimeWeb.CrawlFunc1.get_movie_urls({1,1},"https://ephimmoi.net/category/hoat-hinh/")
  # CrawlAnimeWeb.CrawlFunc1.parse_data(list_data)
  def parse_data(list_data) do
    list_data
    # |> Enum.map(fn item -> HTTPoison.get!(item).body |> Floki.parse_document!() end)
    |> Enum.map(fn item -> HTTPoison.get!(item).body end)
    |> Enum.map(fn body ->
      # Task.async(fn ->
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
      # end)

    end)




    # |> get_movie_html_body()
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
  # def get_movie_html_body(urls) do
  #   Enum.map(urls, fn product_id ->
  #     Task.async(fn -> HttpClient.get(product_id) end)
  #   end)
  #   |> Enum.map(&Task.await(&1, 10000))
  # end




end
