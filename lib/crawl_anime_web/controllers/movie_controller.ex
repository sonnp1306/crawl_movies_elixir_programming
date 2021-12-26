defmodule CrawlAnimeWeb.MovieController do
  use CrawlAnimeWeb, :controller
  alias CrawlAnime.Movies
  alias CrawlAnimeWeb.CrawlFunc



  def index(conn, _params) do
    movies = Movies.list_movies()
    render(conn, "index.json", movies: movies)
  end

  # def create(conn, %{"movie" => movie_params}) do
  #   with {:ok, %Movie{} = movie} <- Movies.create_movie(movie_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", Routes.movie_path(conn, :show, movie))
  #     |> render("show.json", movie: movie)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   movie = Movies.get_movie!(id)
  #   render(conn, "show.json", movie: movie)
  # end

  # def update(conn, %{"id" => id, "movie" => movie_params}) do
  #   movie = Movies.get_movie!(id)

  #   with {:ok, %Movie{} = movie} <- Movies.update_movie(movie, movie_params) do
  #     render(conn, "show.json", movie: movie)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   movie = Movies.get_movie!(id)

  #   with {:ok, %Movie{}} <- Movies.delete_movie(movie) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end


  def crawler_url(conn, %{"page_index" => page_index, "page_size" => page_size, "url" => url}) do
    list_src = get_temp(page_index, page_size) |> CrawlFunc.get_movie_urls(url)
    movies = CrawlFunc.parse_data(list_src)

    # render(conn, "index.json", movies: movies)
    conn |> json(%{status: 1, data: movies})
  end

   # Tính số lượng phần tử bắt đầu và kết thúc tương ứng với page_index và page_size.
  @spec calulate_page_size(number, number) :: {number, number, integer}
  def calulate_page_size(page_index, page_size) do
    {
      page_size * (page_index - 1) + 1,
      page_index * page_size,
      floor((page_index * page_size)/32) + 1,
    }
  end


  def get_temp(page_index, page_size) do
    from = page_size * (page_index - 1) + 1
    to = page_index * page_size
    {
      from,
      to,
      floor(from / 32) + 1,
      floor(to / 32) + 1
    }

  end

    # Tính số trang tương ứng cần lấy trên iphimmoi, do iphimmoi phân trang 32 item/page.
    # @spec calulate_source_page_index({number, number}) :: {integer, integer}
    # def calulate_source_page_index({from, to}) do
    #   {
    #     floor(from / 32) + 1,
    #     floor(to / 32) + 1
    #   }
    # end


end
