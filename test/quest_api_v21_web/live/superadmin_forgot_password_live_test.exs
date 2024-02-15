defmodule QuestApiV21Web.SuperadminForgotPasswordLiveTest do
  use QuestApiV21Web.ConnCase

  import Phoenix.LiveViewTest
  import QuestApiV21.AdminFixtures

  alias QuestApiV21.Admin
  alias QuestApiV21.Repo

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/superadmin/reset_password")

      assert html =~ "Forgot your password?"
      assert has_element?(lv, ~s|a[href="#{~p"/superadmin/register"}"]|, "Register")
      assert has_element?(lv, ~s|a[href="#{~p"/superadmin/log_in"}"]|, "Log in")
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_superadmin(superadmin_fixture())
        |> live(~p"/superadmin/reset_password")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{superadmin: superadmin_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, superadmin: superadmin} do
      {:ok, lv, _html} = live(conn, ~p"/superadmin/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", superadmin: %{"email" => superadmin.email})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"

      assert Repo.get_by!(Admin.SuperadminToken, superadmin_id: superadmin.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/superadmin/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", superadmin: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"
      assert Repo.all(Admin.SuperadminToken) == []
    end
  end
end
