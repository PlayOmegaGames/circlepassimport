defmodule QuestApiV21Web.Collection_PointControllerTest do
  use QuestApiV21Web.ConnCase

  import QuestApiV21.Collection_PointsFixtures

  alias QuestApiV21.Collection_Points.Collection_Point

  @create_attrs %{
    badge_description: "some badge_description",
    image: "some image",
    name: "some name",
    redirect_url: "some redirect_url",
    scans: 42
  }
  @update_attrs %{
    badge_description: "some updated badge_description",
    image: "some updated image",
    name: "some updated name",
    redirect_url: "some updated redirect_url",
    scans: 43
  }
  @invalid_attrs %{badge_description: nil, image: nil, name: nil, redirect_url: nil, scans: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all collection_point", %{conn: conn} do
      conn = get(conn, ~p"/api/collection_point")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create collection__point" do
    test "renders collection__point when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/collection_point", collection__point: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/collection_point/#{id}")

      assert %{
               "id" => ^id,
               "badge_description" => "some badge_description",
               "image" => "some image",
               "name" => "some name",
               "redirect_url" => "some redirect_url",
               "scans" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/collection_point", collection__point: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update collection__point" do
    setup [:create_collection__point]

    test "renders collection__point when data is valid", %{conn: conn, collection__point: %Collection_Point{id: id} = collection__point} do
      conn = put(conn, ~p"/api/collection_point/#{collection__point}", collection__point: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/collection_point/#{id}")

      assert %{
               "id" => ^id,
               "badge_description" => "some updated badge_description",
               "image" => "some updated image",
               "name" => "some updated name",
               "redirect_url" => "some updated redirect_url",
               "scans" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, collection__point: collection__point} do
      conn = put(conn, ~p"/api/collection_point/#{collection__point}", collection__point: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete collection__point" do
    setup [:create_collection__point]

    test "deletes chosen collection__point", %{conn: conn, collection__point: collection__point} do
      conn = delete(conn, ~p"/api/collection_point/#{collection__point}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/collection_point/#{collection__point}")
      end
    end
  end

  defp create_collection__point(_) do
    collection__point = collection__point_fixture()
    %{collection__point: collection__point}
  end
end
