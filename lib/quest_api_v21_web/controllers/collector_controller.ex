defmodule QuestApiV21Web.CollectorController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Collectors
  alias QuestApiV21.Collectors.Collector
  alias QuestApiV21Web.JWTUtility

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    collectors = Collectors.list_collectors()
    |> QuestApiV21.Repo.preload([:badges, :quests])

    render(conn, :index, collectors: collectors)
  end

  def create(conn, %{"collector" => collector_params}) do
    organization_id = JWTUtility.extract_primary_organization_id_from_jwt(conn)

    case Collectors.create_collector_with_organization(collector_params, organization_id) do
      {:ok, collector} ->
        collector = QuestApiV21.Repo.preload(collector, [:badges, :quests])
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/collector/#{collector}")
        |> render(:show, collector: collector)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{message: "Collector creation failed", errors: changeset})
    end
  end

  def show(conn, %{"id" => id}) do
    collector = Collectors.get_collector!(id)
    |> QuestApiV21.Repo.preload([:badges, :quests])

    render(conn, :show, collector: collector)
  end

  def update(conn, %{"id" => id, "collector" => collector_params}) do
    collector = Collectors.get_collector!(id)

    with {:ok, %Collector{} = collector} <- Collectors.update_collector(collector, collector_params) do
      collector = QuestApiV21.Repo.preload(collector, [:badges, :quests])
      render(conn, :show, collector: collector)
    end
  end


  def delete(conn, %{"id" => id}) do
    collector = Collectors.get_collector!(id)

    with {:ok, %Collector{}} <- Collectors.delete_collector(collector) do
      send_resp(conn, :no_content, "")
    end
  end

  #badge page
  def show_collector(conn, %{"id" => id}) do
    # Here, you can add logic to fetch data based on the collector ID if needed.
    render(conn, "collector.html", id: id)
  end

end
