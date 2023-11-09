defmodule QuestApiV21.GuardianErrorHandler do
  import Plug.Conn

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{error: "You must be authenticated to access this resource."}))
    |> halt()
  end
end
