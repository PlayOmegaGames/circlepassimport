defmodule QuestApiV21Web.BubbleController do
  use QuestApiV21Web, :controller

  def bubble_wrap(conn, %{"jwt_token" => jwt_token, "endpoint" => endpoint, "method" => method, "body" => body} = _params) do
    target_url = "https://questapp.io/" <> endpoint

    # Dynamically handling the request body
    # Assuming the `body` is already a properly structured JSON map
    encoded_body = Jason.encode!(body)

    case dispatch_request(method, target_url, jwt_token, encoded_body) do
      {:ok, %HTTPoison.Response{status_code: code, body: response_body}} when code in [200, 201] ->
        conn
        |> put_status(code) # Reflect the actual status code from the response
        |> json(%{success: true, data: Jason.decode!(response_body)})

      {:ok, %HTTPoison.Response{status_code: code, body: response_body}} ->
        # Handling client or server error responses (4xx, 5xx) from the external API
        conn
        |> put_status(code) # Reflect the external API's error status code
        |> json(%{error: Jason.decode!(response_body)}) # Pass on the error message

      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
        |> put_status(500)
        |> json(%{error: "Request to #{target_url} failed: #{reason}"})

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{error: reason})
    end
  end

  def dispatch_request(method, target_url, jwt_token, encoded_body \\ "") do
    headers = [
      {"Authorization", "Bearer #{jwt_token}"},
      {"Content-Type", "application/json"}
    ]

    case method do
      "GET" ->
        HTTPoison.get(target_url, headers)
      "POST" ->
        HTTPoison.post(target_url, encoded_body, headers)
      _ ->
        {:error, "Unsupported method"}
    end
  end
end
