defmodule QuestApiV21Web.HostControllerTest do
  use QuestApiV21Web.ConnCase

  import QuestApiV21.HostsFixtures

  alias QuestApiV21.Hosts.Host

  @create_attrs %{
    email: "some email",
    hashed_password: "some hashed_password",
    name: "some name"
  }
  @update_attrs %{
    email: "some updated email",
    hashed_password: "some updated hashed_password",
    name: "some updated name"
  }
  @invalid_attrs %{email: nil, hashed_password: nil, name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all hosts", %{conn: conn} do
      conn = get(conn, ~p"/api/hosts")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create host" do
    test "renders host when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/hosts", host: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/hosts/#{id}")

      assert %{
               "id" => ^id,
               "email" => "some email",
               "hashed_password" => "some hashed_password",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/hosts", host: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update host" do
    setup [:create_host]

    test "renders host when data is valid", %{conn: conn, host: %Host{id: id} = host} do
      conn = put(conn, ~p"/api/hosts/#{host}", host: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/hosts/#{id}")

      assert %{
               "id" => ^id,
               "email" => "some updated email",
               "hashed_password" => "some updated hashed_password",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, host: host} do
      conn = put(conn, ~p"/api/hosts/#{host}", host: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete host" do
    setup [:create_host]

    test "deletes chosen host", %{conn: conn, host: host} do
      conn = delete(conn, ~p"/api/hosts/#{host}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/hosts/#{host}")
      end
    end
  end

  defp create_host(_) do
    host = host_fixture()
    %{host: host}
  end
end
