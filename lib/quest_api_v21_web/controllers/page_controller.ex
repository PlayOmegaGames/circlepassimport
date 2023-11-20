defmodule QuestApiV21Web.PageController do
  use QuestApiV21Web, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def sign_in(conn, _params) do
    render(conn, "sign_in.html")
  end

  def sign_up(conn, _params) do
    render(conn, "sign_up.html")
  end
end
