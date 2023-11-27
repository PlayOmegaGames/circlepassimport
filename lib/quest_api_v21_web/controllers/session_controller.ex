defmodule QuestApiV21Web.SessionController do
  use QuestApiV21Web, :controller

  def set_session(conn, %{"account_id" => account_id}) do
    # Set the user_id in the session
    conn
    |> put_session(:user_id, account_id)
    |> send_resp(200, "Session updated")
  end
end
