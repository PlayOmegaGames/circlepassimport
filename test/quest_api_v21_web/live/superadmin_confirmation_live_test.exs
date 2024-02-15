defmodule QuestApiV21Web.SuperadminConfirmationLiveTest do
  use QuestApiV21Web.ConnCase

  import Phoenix.LiveViewTest
  import QuestApiV21.AdminFixtures

  alias QuestApiV21.Admin
  alias QuestApiV21.Repo

  setup do
    %{superadmin: superadmin_fixture()}
  end

  describe "Confirm superadmin" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/superadmin/confirm/some-token")
      assert html =~ "Confirm Account"
    end

    test "confirms the given token once", %{conn: conn, superadmin: superadmin} do
      token =
        extract_superadmin_token(fn url ->
          Admin.deliver_superadmin_confirmation_instructions(superadmin, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/superadmin/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Superadmin confirmed successfully"

      assert Admin.get_superadmin!(superadmin.id).confirmed_at
      refute get_session(conn, :superadmin_token)
      assert Repo.all(Admin.SuperadminToken) == []

      # when not logged in
      {:ok, lv, _html} = live(conn, ~p"/superadmin/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Superadmin confirmation link is invalid or it has expired"

      # when logged in
      conn =
        build_conn()
        |> log_in_superadmin(superadmin)

      {:ok, lv, _html} = live(conn, ~p"/superadmin/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, superadmin: superadmin} do
      {:ok, lv, _html} = live(conn, ~p"/superadmin/confirm/invalid-token")

      {:ok, conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Superadmin confirmation link is invalid or it has expired"

      refute Admin.get_superadmin!(superadmin.id).confirmed_at
    end
  end
end
