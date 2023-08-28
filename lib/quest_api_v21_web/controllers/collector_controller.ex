defmodule QuestApiV21Web.CollectorController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Collectors
  alias QuestApiV21.Collectors.Collector

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    collectors = Collectors.list_collectors()
    |> QuestApiV21.Repo.preload([:collection_points, :quests])

    render(conn, :index, collectors: collectors)
  end

  def create(conn, %{"collector" => collector_params}) do
    with {:ok, %Collector{} = collector} <- Collectors.create_collector(collector_params) do
      collector = QuestApiV21.Repo.preload(collector, [:quests, :collection_points])
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/collectors/#{collector}")
      |> render(:show, collector: collector)
    end
  end

  def show(conn, %{"id" => id}) do
    collector = Collectors.get_collector!(id)
    |> QuestApiV21.Repo.preload([:collection_points, :quests])


    render(conn, :show, collector: collector)
  end

  def update(conn, %{"id" => id, "collector" => collector_params}) do
    collector = Collectors.get_collector!(id)

    with {:ok, %Collector{} = collector} <- Collectors.update_collector(collector, collector_params) do
      render(conn, :show, collector: collector)
    end
  end

  def delete(conn, %{"id" => id}) do
    collector = Collectors.get_collector!(id)

    with {:ok, %Collector{}} <- Collectors.delete_collector(collector) do
      send_resp(conn, :no_content, "")
    end
  end
end
