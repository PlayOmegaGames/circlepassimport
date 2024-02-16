defmodule QuestApiV21Web.ScanControllerTest do
  use QuestApiV21Web.ConnCase

  import QuestApiV21.ScansFixtures

  alias QuestApiV21.Scans.Scan

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all scans", %{conn: conn} do
      conn = get(conn, ~p"/api/scans")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create scan" do
    test "renders scan when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/scans", scan: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/scans/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/scans", scan: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update scan" do
    setup [:create_scan]

    test "renders scan when data is valid", %{conn: conn, scan: %Scan{id: id} = scan} do
      conn = put(conn, ~p"/api/scans/#{scan}", scan: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/scans/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, scan: scan} do
      conn = put(conn, ~p"/api/scans/#{scan}", scan: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete scan" do
    setup [:create_scan]

    test "deletes chosen scan", %{conn: conn, scan: scan} do
      conn = delete(conn, ~p"/api/scans/#{scan}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/scans/#{scan}")
      end
    end
  end

  defp create_scan(_) do
    scan = scan_fixture()
    %{scan: scan}
  end
end
