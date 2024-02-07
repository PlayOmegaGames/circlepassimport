defmodule QuestApiV21Web.BubbleController do
  use QuestApiV21Web, :controller

  def bubble_wrap(conn, %{"jwt_token" => jwt_token} = _params) do
    # The path to the sacred /api/organizations
    target_url = "https://questapp.io/api/organizations"

    # Adorning the request with the JWT token received
    headers = [
      {"Authorization", "Bearer #{jwt_token}"},
      {"Content-Type", "application/json"}
    ]

    # Embarking upon the GET request with the token as its herald
    case HTTPoison.get(target_url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        conn
        |> put_status(200)
        |> json(%{success: true, data: Jason.decode!(response_body)})

      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
        |> put_status(500)
        |> json(%{error: "Request to /api/organizations failed: #{reason}"})
    end
  end
end
