defmodule QuestApiV21Web.Web.PageController do
  use QuestApiV21Web, :controller
  require Logger

  def home(conn, _params) do
    # IO.inspect(conn)

    render(conn, "home.html")
  end
end
