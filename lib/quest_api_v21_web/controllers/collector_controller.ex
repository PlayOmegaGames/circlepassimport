defmodule QuestApiV21Web.CollectorController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Collectors
  alias QuestApiV21.Collectors.Collector
  alias QuestApiV21Web.JWTUtility


  require Logger

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
        # Temporarily bypass QR code generation
         url = "questapp.io/badge/#{collector.id}"
         case QuestApiV21Web.QrGenerator.create_and_upload_qr(url) do
           {:ok, qr_code_url} ->
            collector = QuestApiV21.Repo.preload(collector, [:badges, :quests])
            conn
            |> put_status(:created)
            |> put_resp_header("location", ~p"/api/collector/#{collector}")
            |> render(:show, collector: collector, qr_code_url: qr_code_url) # or qr_code_url: nil
         end

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{message: "Collector creation failed", errors: changeset})
    end
  end


  def show(conn, %{"id" => id}) do
    case Collectors.get_collector(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", message: "Collector not found")

      %Collector{} = collector ->
        render(conn, :show, collector: collector)
    end
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

end
