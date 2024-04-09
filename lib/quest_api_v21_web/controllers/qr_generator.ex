defmodule QuestApiV21Web.QrGenerator do
  # Function to create a QR code from the given url and upload it to AWS S3
  def create_and_upload_qr(url) do
    case request_qrcode(url) do
      {:ok, qr_code} ->
        bucket = "qr-codes-public"
        s3_path = "prod/#{unique_identifier(url)}.svg"
        content_disposition = "inline; filename=\"#{Path.basename(s3_path)}\""

        options = [
          {:content_type, "image/svg+xml"},
          {:content_disposition, content_disposition}
        ]

        case ExAws.S3.put_object(bucket, s3_path, qr_code, options) |> ExAws.request() do
          {:ok, _response} ->
            # Construct the public URL
            # Make sure your S3 bucket is configured for public access if you use this method
            public_url = "https://#{bucket}.s3.amazonaws.com/#{s3_path}"
            {:ok, public_url}

          {:error, error} ->
            {:error, error}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Generates a unique identifier for the QR code based on the provided url
  defp unique_identifier(url), do: "#{url}-#{:erlang.unique_integer([:positive])}"

  def request_qrcode(url) do
    api_url = "https://qrcode-monkey.p.rapidapi.com/qr/custom"

    headers = [
      {"Content-Type", "application/json"},
      {"X-RapidAPI-Key", System.get_env("QR_CODE_MONKEY")},
      {"X-RapidAPI-Host", "qrcode-monkey.p.rapidapi.com"}
    ]

    body = %{
      data: "https://" <> url,
      config: %{
        body: "circular",
        eye: "frame2",
        eyeBall: "ball2",
        erf1: ["fv"],
        erf2: [],
        erf3: [],
        brf1: ["fv"],
        brf2: [],
        brf3: [],
        eyeBall1Color: "#000000",
        eyeBall2Color: "#000000",
        eyeBall3Color: "#000000",
        bodyColor: "#000000",
        logo:
          "https://quest-optimized-images.s3.amazonaws.com/optimized-images/webapp-images/QuestLogo.png",
        logoMode: "clean"
      },
      size: 900,
      file: "svg"
    }

    # IO.inspect(body)

    case HTTPoison.post(api_url, Jason.encode!(body), headers) do
      {:ok, %{status_code: 200, body: response_body}} ->
        # Directly return the binary data of the QR code
        {:ok, response_body}

      {:ok, %{status_code: _status_code, body: _body}} ->
        {:error, "Unexpected success response"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "API request failed: #{reason}"}
    end
  end
end
