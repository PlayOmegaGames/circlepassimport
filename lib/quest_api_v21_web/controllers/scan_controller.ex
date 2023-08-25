defmodule QuestApiV21Web.ScanController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Scans
  alias QuestApiV21.Scans.Scan

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    scans = Scans.list_scans()


    render(conn, :index, scans: scans)
  end

  def create(conn, %{"scan" => scan_params}) do
    with {:ok, %Scan{} = scan} <- Scans.create_scan(scan_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/scans/#{scan}")
      |> render(:show, scan: scan)
    end
  end

  def show(conn, %{"id" => id}) do
    scan = Scans.get_scan!(id)
    render(conn, :show, scan: scan)
  end

  def update(conn, %{"id" => id, "scan" => scan_params}) do
    scan = Scans.get_scan!(id)

    with {:ok, %Scan{} = scan} <- Scans.update_scan(scan, scan_params) do
      render(conn, :show, scan: scan)
    end
  end

  def delete(conn, %{"id" => id}) do
    scan = Scans.get_scan!(id)

    with {:ok, %Scan{}} <- Scans.delete_scan(scan) do
      send_resp(conn, :no_content, "")
    end
  end
end
