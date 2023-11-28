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
end
