defmodule QuestApiV21Web.SuperadminSessionControllerTest do
  use QuestApiV21Web.ConnCase, async: true

  import QuestApiV21.AdminFixtures

  setup do
    %{superadmin: superadmin_fixture()}
  end

  describe "POST /superadmin/log_in" do
    test "logs the superadmin in", %{conn: conn, superadmin: superadmin} do
      conn =
        post(conn, ~p"/superadmin/log_in", %{
          "superadmin" => %{
            "email" => superadmin.email,
            "password" => valid_superadmin_password()
          }
        })

      assert get_session(conn, :superadmin_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ superadmin.email
      assert response =~ ~p"/superadmin/settings"
      assert response =~ ~p"/superadmin/log_out"
    end

    test "logs the superadmin in with remember me", %{conn: conn, superadmin: superadmin} do
      conn =
        post(conn, ~p"/superadmin/log_in", %{
          "superadmin" => %{
            "email" => superadmin.email,
            "password" => valid_superadmin_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_quest_api_v21_web_superadmin_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the superadmin in with return to", %{conn: conn, superadmin: superadmin} do
      conn =
        conn
        |> init_test_session(superadmin_return_to: "/foo/bar")
        |> post(~p"/superadmin/log_in", %{
          "superadmin" => %{
            "email" => superadmin.email,
            "password" => valid_superadmin_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "login following registration", %{conn: conn, superadmin: superadmin} do
      conn =
        conn
        |> post(~p"/superadmin/log_in", %{
          "_action" => "registered",
          "superadmin" => %{
            "email" => superadmin.email,
            "password" => valid_superadmin_password()
          }
        })

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Account created successfully"
    end

    test "login following password update", %{conn: conn, superadmin: superadmin} do
      conn =
        conn
        |> post(~p"/superadmin/log_in", %{
          "_action" => "password_updated",
          "superadmin" => %{
            "email" => superadmin.email,
            "password" => valid_superadmin_password()
          }
        })

      assert redirected_to(conn) == ~p"/superadmin/settings"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password updated successfully"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/superadmin/log_in", %{
          "superadmin" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == ~p"/superadmin/log_in"
    end
  end

  describe "DELETE /superadmin/log_out" do
    test "logs the superadmin out", %{conn: conn, superadmin: superadmin} do
      conn = conn |> log_in_superadmin(superadmin) |> delete(~p"/superadmin/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :superadmin_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the superadmin is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/superadmin/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :superadmin_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
