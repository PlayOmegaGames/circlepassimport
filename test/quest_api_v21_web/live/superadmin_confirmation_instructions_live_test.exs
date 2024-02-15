defmodule QuestApiV21Web.SuperadminConfirmationInstructionsLiveTest do
  use QuestApiV21Web.ConnCase

  import Phoenix.LiveViewTest
  import QuestApiV21.AdminFixtures

  alias QuestApiV21.Admin
  alias QuestApiV21.Repo

  setup do
    %{superadmin: superadmin_fixture()}
  end

  describe "Resend confirmation" do
    test "renders the resend confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/superadmin/confirm")
      assert html =~ "Resend confirmation instructions"
    end

    test "sends a new confirmation token", %{conn: conn, superadmin: superadmin} do
      {:ok, lv, _html} = live(conn, ~p"/superadmin/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", superadmin: %{email: superadmin.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(Admin.SuperadminToken, superadmin_id: superadmin.id).context == "confirm"
    end

    test "does not send confirmation token if superadmin is confirmed", %{conn: conn, superadmin: superadmin} do
      Repo.update!(Admin.Superadmin.confirm_changeset(superadmin))

      {:ok, lv, _html} = live(conn, ~p"/superadmin/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", superadmin: %{email: superadmin.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      refute Repo.get_by(Admin.SuperadminToken, superadmin_id: superadmin.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/superadmin/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", superadmin: %{email: "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(Admin.SuperadminToken) == []
    end
  end
end
