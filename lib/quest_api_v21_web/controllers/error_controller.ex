defmodule QuestApiV21Web.ErrorController do
  use QuestApiV21Web, :controller

  def not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "Resource not found"})
  end
end
