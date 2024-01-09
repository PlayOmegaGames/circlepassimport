defmodule QuestApiV21Web.PageController do
  use QuestApiV21Web, :controller

  def home(conn, _params) do
    user_email = get_session(conn, :user_email)
    user_id = get_session(conn, :user_id)

    render(conn, "home.html", user_email: user_email, user_id: user_id)
  end

  def sign_in(conn, _params) do
    render(conn, "sign_in.html")
  end

  def sign_up(conn, _params) do
    render(conn, "sign_up.html")
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html")
  end

  def user_settings(conn, _params) do
    email = conn.assigns.current_user.email
    name = conn.assigns.current_user.name
    user_id = get_session(conn, :user_id)

    #IO.inspect(conn)

    render(conn, "user_settings.html", name: name, email: email, user_id: user_id)
  end

  def auth_splash(conn, _params) do
    conn
    |> put_layout(false)
    |> assign(:body_class, "bg-gradient-to-b from-purple-400 to-purple-800 h-screen")
    |> render("auth_splash.html")
  end
end
