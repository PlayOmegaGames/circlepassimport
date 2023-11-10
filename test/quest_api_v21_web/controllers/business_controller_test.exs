defmodule QuestApiV21Web.OrganizationControllerTest do
  use QuestApiV21Web.ConnCase

  import QuestApiV21.OrganizationsFixtures

  alias QuestApiV21.Organizations.Organization

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all organizations", %{conn: conn} do
      conn = get(conn, ~p"/api/organizations")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create orgaization" do
    test "renders orgaization when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/organizations", orgaization: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/organizations/#{id}")

      assert %{
               "id" => ^id,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/organizations", orgaization: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update orgaization" do
    setup [:create_orgaization]

    test "renders orgaization when data is valid", %{conn: conn, orgaization: %Organization{id: id} = orgaization} do
      conn = put(conn, ~p"/api/organizations/#{orgaization}", orgaization: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/organizations/#{id}")

      assert %{
               "id" => ^id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, orgaization: orgaization} do
      conn = put(conn, ~p"/api/organizations/#{orgaization}", orgaization: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete orgaization" do
    setup [:create_orgaization]

    test "deletes chosen orgaization", %{conn: conn, orgaization: orgaization} do
      conn = delete(conn, ~p"/api/organizations/#{orgaization}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/organizations/#{orgaization}")
      end
    end
  end

  defp create_orgaization(_) do
    orgaization = orgaization_fixture()
    %{orgaization: orgaization}
  end
end
