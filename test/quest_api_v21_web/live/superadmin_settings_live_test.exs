defmodule QuestApiV21Web.SuperadminSettingsLiveTest do
  use QuestApiV21Web.ConnCase

  alias QuestApiV21.Admin
  import Phoenix.LiveViewTest
  import QuestApiV21.AdminFixtures

  describe "Settings page" do
    test "renders settings page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_superadmin(superadmin_fixture())
        |> live(~p"/superadmin/settings")

      assert html =~ "Change Email"
      assert html =~ "Change Password"
    end

    test "redirects if superadmin is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/superadmin/settings")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/superadmin/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "update email form" do
    setup %{conn: conn} do
      password = valid_superadmin_password()
      superadmin = superadmin_fixture(%{password: password})
      %{conn: log_in_superadmin(conn, superadmin), superadmin: superadmin, password: password}
    end

    test "updates the superadmin email", %{conn: conn, password: password, superadmin: superadmin} do
      new_email = unique_superadmin_email()

      {:ok, lv, _html} = live(conn, ~p"/superadmin/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => password,
          "superadmin" => %{"email" => new_email}
        })
        |> render_submit()

      assert result =~ "A link to confirm your email"
      assert Admin.get_superadmin_by_email(superadmin.email)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/superadmin/settings")

      result =
        lv
        |> element("#email_form")
        |> render_change(%{
          "action" => "update_email",
          "current_password" => "invalid",
          "superadmin" => %{"email" => "with spaces"}
        })

      assert result =~ "Change Email"
      assert result =~ "must have the @ sign and no spaces"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn, superadmin: superadmin} do
      {:ok, lv, _html} = live(conn, ~p"/superadmin/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => "invalid",
          "superadmin" => %{"email" => superadmin.email}
        })
        |> render_submit()

      assert result =~ "Change Email"
      assert result =~ "did not change"
      assert result =~ "is not valid"
    end
  end

  describe "update password form" do
    setup %{conn: conn} do
      password = valid_superadmin_password()
      superadmin = superadmin_fixture(%{password: password})
      %{conn: log_in_superadmin(conn, superadmin), superadmin: superadmin, password: password}
    end

    test "updates the superadmin password", %{
      conn: conn,
      superadmin: superadmin,
      password: password
    } do
      new_password = valid_superadmin_password()

      {:ok, lv, _html} = live(conn, ~p"/superadmin/settings")

      form =
        form(lv, "#password_form", %{
          "current_password" => password,
          "superadmin" => %{
            "email" => superadmin.email,
            "password" => new_password,
            "password_confirmation" => new_password
          }
        })

      render_submit(form)

      new_password_conn = follow_trigger_action(form, conn)

      assert redirected_to(new_password_conn) == ~p"/superadmin/settings"

      assert get_session(new_password_conn, :superadmin_token) !=
               get_session(conn, :superadmin_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert Admin.get_superadmin_by_email_and_password(superadmin.email, new_password)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/superadmin/settings")

      result =
        lv
        |> element("#password_form")
        |> render_change(%{
          "current_password" => "invalid",
          "superadmin" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/superadmin/settings")

      result =
        lv
        |> form("#password_form", %{
          "current_password" => "invalid",
          "superadmin" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })
        |> render_submit()

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
      assert result =~ "is not valid"
    end
  end

  describe "confirm email" do
    setup %{conn: conn} do
      superadmin = superadmin_fixture()
      email = unique_superadmin_email()

      token =
        extract_superadmin_token(fn url ->
          Admin.deliver_superadmin_update_email_instructions(
            %{superadmin | email: email},
            superadmin.email,
            url
          )
        end)

      %{
        conn: log_in_superadmin(conn, superadmin),
        token: token,
        email: email,
        superadmin: superadmin
      }
    end

    test "updates the superadmin email once", %{
      conn: conn,
      superadmin: superadmin,
      token: token,
      email: email
    } do
      {:error, redirect} = live(conn, ~p"/superadmin/settings/confirm_email/#{token}")

      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/superadmin/settings"
      assert %{"info" => message} = flash
      assert message == "Email changed successfully."
      refute Admin.get_superadmin_by_email(superadmin.email)
      assert Admin.get_superadmin_by_email(email)

      # use confirm token again
      {:error, redirect} = live(conn, ~p"/superadmin/settings/confirm_email/#{token}")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/superadmin/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
    end

    test "does not update email with invalid token", %{conn: conn, superadmin: superadmin} do
      {:error, redirect} = live(conn, ~p"/superadmin/settings/confirm_email/oops")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/superadmin/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
      assert Admin.get_superadmin_by_email(superadmin.email)
    end

    test "redirects if superadmin is not logged in", %{token: token} do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/superadmin/settings/confirm_email/#{token}")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/superadmin/log_in"
      assert %{"error" => message} = flash
      assert message == "You must log in to access this page."
    end
  end
end
