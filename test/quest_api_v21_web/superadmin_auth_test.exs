defmodule QuestApiV21Web.SuperadminAuthTest do
  use QuestApiV21Web.ConnCase, async: true

  alias Phoenix.LiveView
  alias QuestApiV21.Admin
  alias QuestApiV21Web.SuperadminAuth
  import QuestApiV21.AdminFixtures

  @remember_me_cookie "_quest_api_v21_web_superadmin_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, QuestApiV21Web.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{superadmin: superadmin_fixture(), conn: conn}
  end

  describe "log_in_superadmin/3" do
    test "stores the superadmin token in the session", %{conn: conn, superadmin: superadmin} do
      conn = SuperadminAuth.log_in_superadmin(conn, superadmin)
      assert token = get_session(conn, :superadmin_token)
      assert get_session(conn, :live_socket_id) == "superadmin_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == ~p"/"
      assert Admin.get_superadmin_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, superadmin: superadmin} do
      conn = conn |> put_session(:to_be_removed, "value") |> SuperadminAuth.log_in_superadmin(superadmin)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, superadmin: superadmin} do
      conn = conn |> put_session(:superadmin_return_to, "/hello") |> SuperadminAuth.log_in_superadmin(superadmin)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, superadmin: superadmin} do
      conn = conn |> fetch_cookies() |> SuperadminAuth.log_in_superadmin(superadmin, %{"remember_me" => "true"})
      assert get_session(conn, :superadmin_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :superadmin_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_superadmin/1" do
    test "erases session and cookies", %{conn: conn, superadmin: superadmin} do
      superadmin_token = Admin.generate_superadmin_session_token(superadmin)

      conn =
        conn
        |> put_session(:superadmin_token, superadmin_token)
        |> put_req_cookie(@remember_me_cookie, superadmin_token)
        |> fetch_cookies()
        |> SuperadminAuth.log_out_superadmin()

      refute get_session(conn, :superadmin_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
      refute Admin.get_superadmin_by_session_token(superadmin_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "superadmin_sessions:abcdef-token"
      QuestApiV21Web.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> SuperadminAuth.log_out_superadmin()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if superadmin is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> SuperadminAuth.log_out_superadmin()
      refute get_session(conn, :superadmin_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "fetch_current_superadmin/2" do
    test "authenticates superadmin from session", %{conn: conn, superadmin: superadmin} do
      superadmin_token = Admin.generate_superadmin_session_token(superadmin)
      conn = conn |> put_session(:superadmin_token, superadmin_token) |> SuperadminAuth.fetch_current_superadmin([])
      assert conn.assigns.current_superadmin.id == superadmin.id
    end

    test "authenticates superadmin from cookies", %{conn: conn, superadmin: superadmin} do
      logged_in_conn =
        conn |> fetch_cookies() |> SuperadminAuth.log_in_superadmin(superadmin, %{"remember_me" => "true"})

      superadmin_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> SuperadminAuth.fetch_current_superadmin([])

      assert conn.assigns.current_superadmin.id == superadmin.id
      assert get_session(conn, :superadmin_token) == superadmin_token

      assert get_session(conn, :live_socket_id) ==
               "superadmin_sessions:#{Base.url_encode64(superadmin_token)}"
    end

    test "does not authenticate if data is missing", %{conn: conn, superadmin: superadmin} do
      _ = Admin.generate_superadmin_session_token(superadmin)
      conn = SuperadminAuth.fetch_current_superadmin(conn, [])
      refute get_session(conn, :superadmin_token)
      refute conn.assigns.current_superadmin
    end
  end

  describe "on_mount: mount_current_superadmin" do
    test "assigns current_superadmin based on a valid superadmin_token", %{conn: conn, superadmin: superadmin} do
      superadmin_token = Admin.generate_superadmin_session_token(superadmin)
      session = conn |> put_session(:superadmin_token, superadmin_token) |> get_session()

      {:cont, updated_socket} =
        SuperadminAuth.on_mount(:mount_current_superadmin, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_superadmin.id == superadmin.id
    end

    test "assigns nil to current_superadmin assign if there isn't a valid superadmin_token", %{conn: conn} do
      superadmin_token = "invalid_token"
      session = conn |> put_session(:superadmin_token, superadmin_token) |> get_session()

      {:cont, updated_socket} =
        SuperadminAuth.on_mount(:mount_current_superadmin, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_superadmin == nil
    end

    test "assigns nil to current_superadmin assign if there isn't a superadmin_token", %{conn: conn} do
      session = conn |> get_session()

      {:cont, updated_socket} =
        SuperadminAuth.on_mount(:mount_current_superadmin, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_superadmin == nil
    end
  end

  describe "on_mount: ensure_authenticated" do
    test "authenticates current_superadmin based on a valid superadmin_token", %{conn: conn, superadmin: superadmin} do
      superadmin_token = Admin.generate_superadmin_session_token(superadmin)
      session = conn |> put_session(:superadmin_token, superadmin_token) |> get_session()

      {:cont, updated_socket} =
        SuperadminAuth.on_mount(:ensure_authenticated, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_superadmin.id == superadmin.id
    end

    test "redirects to login page if there isn't a valid superadmin_token", %{conn: conn} do
      superadmin_token = "invalid_token"
      session = conn |> put_session(:superadmin_token, superadmin_token) |> get_session()

      socket = %LiveView.Socket{
        endpoint: QuestApiV21Web.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = SuperadminAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_superadmin == nil
    end

    test "redirects to login page if there isn't a superadmin_token", %{conn: conn} do
      session = conn |> get_session()

      socket = %LiveView.Socket{
        endpoint: QuestApiV21Web.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = SuperadminAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_superadmin == nil
    end
  end

  describe "on_mount: :redirect_if_superadmin_is_authenticated" do
    test "redirects if there is an authenticated  superadmin ", %{conn: conn, superadmin: superadmin} do
      superadmin_token = Admin.generate_superadmin_session_token(superadmin)
      session = conn |> put_session(:superadmin_token, superadmin_token) |> get_session()

      assert {:halt, _updated_socket} =
               SuperadminAuth.on_mount(
                 :redirect_if_superadmin_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end

    test "doesn't redirect if there is no authenticated superadmin", %{conn: conn} do
      session = conn |> get_session()

      assert {:cont, _updated_socket} =
               SuperadminAuth.on_mount(
                 :redirect_if_superadmin_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end
  end

  describe "redirect_if_superadmin_is_authenticated/2" do
    test "redirects if superadmin is authenticated", %{conn: conn, superadmin: superadmin} do
      conn = conn |> assign(:current_superadmin, superadmin) |> SuperadminAuth.redirect_if_superadmin_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == ~p"/"
    end

    test "does not redirect if superadmin is not authenticated", %{conn: conn} do
      conn = SuperadminAuth.redirect_if_superadmin_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_superadmin/2" do
    test "redirects if superadmin is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> SuperadminAuth.require_authenticated_superadmin([])
      assert conn.halted

      assert redirected_to(conn) == ~p"/superadmin/log_in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> SuperadminAuth.require_authenticated_superadmin([])

      assert halted_conn.halted
      assert get_session(halted_conn, :superadmin_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> SuperadminAuth.require_authenticated_superadmin([])

      assert halted_conn.halted
      assert get_session(halted_conn, :superadmin_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> SuperadminAuth.require_authenticated_superadmin([])

      assert halted_conn.halted
      refute get_session(halted_conn, :superadmin_return_to)
    end

    test "does not redirect if superadmin is authenticated", %{conn: conn, superadmin: superadmin} do
      conn = conn |> assign(:current_superadmin, superadmin) |> SuperadminAuth.require_authenticated_superadmin([])
      refute conn.halted
      refute conn.status
    end
  end
end
