defmodule QuestApiV21Web.CollectorControllerTest do
  use QuestApiV21Web.ConnCase

  import QuestApiV21.CollectorsFixtures

  alias QuestApiV21.Collectors.Collector

  @create_attrs %{
    coordinates: "some coordinates",
    height: "some height",
    name: "some name"
  }
  @update_attrs %{
    coordinates: "some updated coordinates",
    height: "some updated height",
    name: "some updated name"
  }
  @invalid_attrs %{coordinates: nil, height: nil, name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all collectors", %{conn: conn} do
      conn = get(conn, ~p"/api/collectors")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create collector" do
    test "renders collector when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/collectors", collector: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/collectors/#{id}")

      assert %{
               "id" => ^id,
               "coordinates" => "some coordinates",
               "height" => "some height",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/collectors", collector: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update collector" do
    setup [:create_collector]

    test "renders collector when data is valid", %{
      conn: conn,
      collector: %Collector{id: id} = collector
    } do
      conn = put(conn, ~p"/api/collectors/#{collector}", collector: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/collectors/#{id}")

      assert %{
               "id" => ^id,
               "coordinates" => "some updated coordinates",
               "height" => "some updated height",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, collector: collector} do
      conn = put(conn, ~p"/api/collectors/#{collector}", collector: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete collector" do
    setup [:create_collector]

    test "deletes chosen collector", %{conn: conn, collector: collector} do
      conn = delete(conn, ~p"/api/collectors/#{collector}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/collectors/#{collector}")
      end
    end
  end

  defp create_collector(_) do
    collector = collector_fixture()
    %{collector: collector}
  end
end
