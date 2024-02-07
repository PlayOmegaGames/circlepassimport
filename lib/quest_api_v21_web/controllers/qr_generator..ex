defmodule QuestApiV21Web.QrGenerator do
  # Function to create a QR code from the given url and upload it to AWS S3
  def create_and_upload_qr(url) do
    # Attempt to create and render a QR code from the provided url
    case QRCode.create(url) |> QRCode.render() do
      # If QR code creation and rendering succeed
      {:ok, qr_code} ->
        # Define the AWS S3 bucket name where the QR code will be stored
        bucket = "quest-api-resources"

        # Construct the S3 path for the QR code, using a unique identifier based on the url
        s3_path = "qr-codes/#{unique_identifier(url)}.png"

        # Upload the generated QR code to S3 and handle the response
        # Note: This line seems redundant and may be a mistake, as the operation is repeated below.
        ExAws.S3.put_object(bucket, s3_path, qr_code)
        |> ExAws.request()
        |> handle_s3_response()

        # Attempt to upload the QR code to S3 again and handle the outcome
        case ExAws.S3.put_object(bucket, s3_path, qr_code) |> ExAws.request() do
          # If upload succeeds, generate and return a presigned URL for accessing the uploaded QR code
          {:ok, _response} ->
            generate_presigned_url(bucket, s3_path) # Return just the URL string

          # If upload fails, return the error
          {:error, error} -> {:error, error}
        end

      # If QR code creation and rendering fail, return the error
      {:error, reason} -> {:error, reason}
    end
  end

  # Generates a unique identifier for the QR code based on the provided url
  defp unique_identifier(url), do: "#{url}-#{:erlang.unique_integer([:positive])}"

  # Generates a presigned URL for the uploaded QR code, allowing secure access without making the object public
  defp generate_presigned_url(bucket, object_path) do
    ExAws.S3.presigned_url(ExAws.Config.new(:s3), :get, bucket, object_path, query_params: [{"response-content-disposition", "attachment"}])
  end

  # Helper function to process successful S3 responses
  defp handle_s3_response({:ok, _response}), do: :ok

  # Helper function to process error responses from S3
  defp handle_s3_response({:error, error}), do: {:error, error}
end
