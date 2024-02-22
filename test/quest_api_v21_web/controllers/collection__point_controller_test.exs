defmodule QuestApiV21Web.BadgeControllerTest do
  use QuestApiV21Web.ConnCase

  import QuestApiV21.BadgesFixtures

  alias QuestApiV21.Badges.Badge

  @create_attrs %{
    badge_description: "some badge_description",
    image: "some image",
    name: "some name",
    redirect_url: "some redirect_url",
    transactions: 42
  }
  @update_attrs %{
    badge_description: "some updated badge_description",
    image: "some updated image",
    name: "some updated name",
    redirect_url: "some updated redirect_url",
    transactions: 43
  }
  @invalid_attrs %{
    badge_description: nil,
    image: nil,
    name: nil,
    redirect_url: nil,
    transactions: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all badge", %{conn: conn} do
      conn = get(conn, ~p"/api/badge")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create badge" do
    test "renders badge when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/badge", badge: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/badge/#{id}")

      assert %{
               "id" => ^id,
               "badge_description" => "some badge_description",
               "image" => "some image",
               "name" => "some name",
               "redirect_url" => "some redirect_url",
               "transactions" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/badge", badge: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update badge" do
    setup [:create_badge]

    test "renders badge when data is valid", %{conn: conn, badge: %Badge{id: id} = badge} do
      conn = put(conn, ~p"/api/badge/#{badge}", badge: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/badge/#{id}")

      assert %{
               "id" => ^id,
               "badge_description" => "some updated badge_description",
               "image" => "some updated image",
               "name" => "some updated name",
               "redirect_url" => "some updated redirect_url",
               "transactions" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, badge: badge} do
      conn = put(conn, ~p"/api/badge/#{badge}", badge: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete badge" do
    setup [:create_badge]

    test "deletes chosen badge", %{conn: conn, badge: badge} do
      conn = delete(conn, ~p"/api/badge/#{badge}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/badge/#{badge}")
      end
    end
  end

  defp create_badge(_) do
    badge = badge_fixture()
    %{badge: badge}
  end
end
