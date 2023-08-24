defmodule QuestApiV21Web.Collection_PointController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Collection_Points
  alias QuestApiV21.Collection_Points.Collection_Point

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    collection_point = Collection_Points.list_collection_point()
    |> QuestApiV21.Repo.preload(:business)

    render(conn, :index, collection_point: collection_point)
  end

  def create(conn, %{"collection__point" => collection__point_params}) do
    with {:ok, %Collection_Point{} = collection__point} <- Collection_Points.create_collection__point(collection__point_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/collection_point/#{collection__point}")
      |> render(:show, collection__point: collection__point)
    end
  end

  def show(conn, %{"id" => id}) do
    collection__point = Collection_Points.get_collection__point!(id)
    |> QuestApiV21.Repo.preload(:business)


    render(conn, :show, collection__point: collection__point)
  end

  def update(conn, %{"id" => id, "collection__point" => collection__point_params}) do
    collection__point = Collection_Points.get_collection__point!(id)

    with {:ok, %Collection_Point{} = collection__point} <- Collection_Points.update_collection__point(collection__point, collection__point_params) do
      render(conn, :show, collection__point: collection__point)
    end
  end

  def delete(conn, %{"id" => id}) do
    collection__point = Collection_Points.get_collection__point!(id)

    with {:ok, %Collection_Point{}} <- Collection_Points.delete_collection__point(collection__point) do
      send_resp(conn, :no_content, "")
    end
  end
end
