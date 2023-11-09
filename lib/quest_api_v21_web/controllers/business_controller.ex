defmodule QuestApiV21Web.BusinessController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Businesses
  alias QuestApiV21.Businesses.Business

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    businesses = Businesses.list_businesses()
    |> QuestApiV21.Repo.preload([:hosts, :quests, :badges, :collectors])


    render(conn, :index, businesses: businesses)
  end

  def create(conn, %{"business" => business_params}) do
    with {:ok, %Business{} = business} <- Businesses.create_business(business_params) do
      business = QuestApiV21.Repo.preload(business, [:hosts, :quests, :badges, :collectors])
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/businesses/#{business}")
      |> render(:show, business: business)
    end
  end

  def show(conn, %{"id" => id}) do
    business = Businesses.get_business!(id)
    |> QuestApiV21.Repo.preload([:hosts, :quests, :badges, :collectors])

    render(conn, :show, business: business)
  end

  def update(conn, %{"id" => id, "business" => business_params}) do
    business = Businesses.get_business!(id)

    with {:ok, %Business{} = business} <- Businesses.update_business(business, business_params) do
      render(conn, :show, business: business)
    end
  end

  def delete(conn, %{"id" => id}) do
    business = Businesses.get_business!(id)

    with {:ok, %Business{}} <- Businesses.delete_business(business) do
      send_resp(conn, :no_content, "")
    end
  end
end
