defmodule QuestApiV21.GuardianErrorHandler do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  @behaviour Guardian.Plug.ErrorHandler

  # This function matches the callback required by Guardian 2.3.2
  def auth_error(conn, {type, reason}, _opts) do
    message =
      case {type, reason} do
        {:unauthenticated, :no_claims_provided} ->
          "No authentication token provided."

        {:unauthenticated, :claims_invalid} ->
          "Invalid token: #{reason}."

        {:unauthenticated, :unauthorized} ->
          "Unauthorized access: #{reason}."

        _ ->
          "Unknown authentication error."
      end

    respond_with_error(conn, message)
  end

  defp respond_with_error(conn, message) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: message})
    |> halt()
  end
end
