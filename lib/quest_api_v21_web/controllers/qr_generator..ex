defmodule QuestApiV21Web.QrGenerator do
  def create_and_upload_qr(text) do
    case QRCode.create(text) |> QRCode.render() do
      {:ok, qr_code} ->
        bucket = "quest-api-resources"
        s3_path = "qr-codes/#{unique_identifier(text)}.png"

        ExAws.S3.put_object(bucket, s3_path, qr_code)
        |> ExAws.request()
        |> handle_s3_response()

        case ExAws.S3.put_object(bucket, s3_path, qr_code) |> ExAws.request() do
          {:ok, _response} ->
            generate_presigned_url(bucket, s3_path) # Return just the URL string
          {:error, error} -> {:error, error}
        end

      {:error, reason} -> {:error, reason}
    end
  end

  defp unique_identifier(text), do: "#{text}-#{:erlang.unique_integer([:positive])}"

  defp generate_presigned_url(bucket, object_path) do
    ExAws.S3.presigned_url(ExAws.Config.new(:s3), :get, bucket, object_path, query_params: [{"response-content-disposition", "attachment"}])
  end

  defp handle_s3_response({:ok, _response}), do: :ok
  defp handle_s3_response({:error, error}), do: {:error, error}
end
