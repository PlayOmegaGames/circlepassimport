defmodule QuestApiV21Web.BusinessControllerTest do
  use QuestApiV21Web.ConnCase

  import QuestApiV21.BusinessesFixtures

  alias QuestApiV21.Businesses.Business

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
    test "lists all businesses", %{conn: conn} do
      conn = get(conn, ~p"/api/businesses")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create business" do
    test "renders business when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/businesses", business: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/businesses/#{id}")

      assert %{
               "id" => ^id,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/businesses", business: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update business" do
    setup [:create_business]

    test "renders business when data is valid", %{conn: conn, business: %Business{id: id} = business} do
      conn = put(conn, ~p"/api/businesses/#{business}", business: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/businesses/#{id}")

      assert %{
               "id" => ^id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, business: business} do
      conn = put(conn, ~p"/api/businesses/#{business}", business: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete business" do
    setup [:create_business]

    test "deletes chosen business", %{conn: conn, business: business} do
      conn = delete(conn, ~p"/api/businesses/#{business}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/businesses/#{business}")
      end
    end
  end

  defp create_business(_) do
    business = business_fixture()
    %{business: business}
  end
end
