defmodule QuestApiV21Web.AuthControllerTest do
  use QuestApiV21Web.ConnCase, async: true

  alias QuestApiV21.Accounts
  alias QuestApiV21.Repo

  @valid_attrs %{
    "email" => "test@example.com",
    "password" => "password123",
    "name" => "Test User"
  }

  @invalid_attrs %{
    "email" => "invalid",
    "password" => "short",
    "name" => ""
  }

  describe "sign_up" do
    test "with valid data creates an account and returns 201 status with JWT", %{conn: conn} do
      conn
      |> Ecto.Adapters.SQL.begin_test_transaction()  # Start a transaction for data setup

      # Ensure no existing account with the same email
      assert Accounts.find_account_by_email("test@example.com") == nil

      response =
        conn
        |> post("/api/sign_up", account: @valid_attrs)
        |> json_response(201)

      assert "Bearer " <> jwt = get_resp_header(conn, "authorization") |> List.first()
      assert "test@example.com" = response["email"]

      conn
      |> Ecto.Adapters.SQL.rollback_test_transaction()  # Rollback the transaction after the test
    end

    test "with invalid data returns 422 status with error messages", %{conn: conn} do
      response =
        conn
        |> post("/api/sign_up", account: @invalid_attrs)
        |> json_response(422)

      assert response["errors"] != %{}
    end
  end
end
