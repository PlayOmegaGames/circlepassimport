defmodule QuestApiV21Web.CollectorController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Collectors
  alias QuestApiV21.Collectors.Collector
  alias QuestApiV21Web.JWTUtility
  alias QuestApiV21.Repo

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    organization_ids = JWTUtility.get_organization_ids_from_jwt(conn)
    collectors = Collectors.list_collectors_by_organization_ids(organization_ids)
                |> Repo.preload([:badges, :quests])

    render(conn, :index, collectors: collectors)
  end

  def create(conn, %{"collector" => collector_params}) do
    organization_id = JWTUtility.extract_primary_organization_id_from_jwt(conn)

    case Collectors.create_collector_with_organization(collector_params, organization_id) do
      {:ok, collector} ->
        # Assuming QR code generation logic is correct and remains unchanged
        url = "questapp.io/badge/#{collector.id}"
        case QuestApiV21Web.QrGenerator.create_and_upload_qr(url) do
          {:ok, qr_code_url} ->
            collector = Repo.preload(collector, [:badges, :quests])
            conn
            |> put_status(:created)
            |> put_resp_header("location", ~p"/api/collector/#{collector.id}")
            |> render("show.json", collector: collector, qr_code_url: qr_code_url)
        end

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{message: "Collector creation failed", errors: changeset})
    end
  end

  def show(conn, %{"id" => id}) do
    organization_ids = JWTUtility.get_organization_ids_from_jwt(conn)

    case Collectors.get_collector(id, organization_ids) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", message: "Collector not found")

      %Collector{} = collector ->
        render(conn, "show.json", collector: collector)
    end
  end

  def update(conn, %{"id" => id, "collector" => collector_params}) do
    organization_ids = JWTUtility.get_organization_ids_from_jwt(conn)

    case Collectors.get_collector(id, organization_ids) do
      nil ->
        send_resp(conn, :not_found, "")
      %Collector{} = collector ->
        case Collectors.update_collector(collector, collector_params, organization_ids) do
          {:ok, updated_collector} ->
            updated_collector = Repo.preload(updated_collector, [:badges, :quests])
            render(conn, "show.json", collector: updated_collector)
          {:error, :unauthorized} ->
            send_resp(conn, :forbidden, "")
          {:error, _changeset} ->
            send_resp(conn, :unprocessable_entity, "")
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    organization_ids = JWTUtility.get_organization_ids_from_jwt(conn)

    case Collectors.get_collector(id, organization_ids) do
      nil ->
        send_resp(conn, :not_found, "")
      %Collector{} = collector ->
        case Collectors.delete_collector(collector, organization_ids) do
          {:ok, %Collector{}} ->
            send_resp(conn, :no_content, "")
          {:error, :unauthorized} ->
            send_resp(conn, :forbidden, "")
        end
    end
  end
end
