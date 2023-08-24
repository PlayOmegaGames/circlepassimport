defmodule QuestApiV21Web.QuestControllerTest do
  use QuestApiV21Web.ConnCase

  import QuestApiV21.QuestsFixtures

  alias QuestApiV21.Quests.Quest

  @create_attrs %{
    address: "some address",
    end-date: ~D[2023-08-23],
    name: "some name",
    quest-type: "some quest-type",
    redemption: "some redemption",
    reward: "some reward",
    scans: 42,
    start-date: ~D[2023-08-23]
  }
  @update_attrs %{
    address: "some updated address",
    end-date: ~D[2023-08-24],
    name: "some updated name",
    quest-type: "some updated quest-type",
    redemption: "some updated redemption",
    reward: "some updated reward",
    scans: 43,
    start-date: ~D[2023-08-24]
  }
  @invalid_attrs %{address: nil, "end-date": nil, name: nil, "quest-type": nil, redemption: nil, reward: nil, scans: nil, "start-date": nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all quests", %{conn: conn} do
      conn = get(conn, ~p"/api/quests")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create quest" do
    test "renders quest when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/quests", quest: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/quests/#{id}")

      assert %{
               "id" => ^id,
               "address" => "some address",
               "end-date" => "2023-08-23",
               "name" => "some name",
               "quest-type" => "some quest-type",
               "redemption" => "some redemption",
               "reward" => "some reward",
               "scans" => 42,
               "start-date" => "2023-08-23"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/quests", quest: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update quest" do
    setup [:create_quest]

    test "renders quest when data is valid", %{conn: conn, quest: %Quest{id: id} = quest} do
      conn = put(conn, ~p"/api/quests/#{quest}", quest: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/quests/#{id}")

      assert %{
               "id" => ^id,
               "address" => "some updated address",
               "end-date" => "2023-08-24",
               "name" => "some updated name",
               "quest-type" => "some updated quest-type",
               "redemption" => "some updated redemption",
               "reward" => "some updated reward",
               "scans" => 43,
               "start-date" => "2023-08-24"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, quest: quest} do
      conn = put(conn, ~p"/api/quests/#{quest}", quest: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete quest" do
    setup [:create_quest]

    test "deletes chosen quest", %{conn: conn, quest: quest} do
      conn = delete(conn, ~p"/api/quests/#{quest}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/quests/#{quest}")
      end
    end
  end

  defp create_quest(_) do
    quest = quest_fixture()
    %{quest: quest}
  end
end
