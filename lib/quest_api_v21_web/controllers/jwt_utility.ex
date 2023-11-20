defmodule QuestApiV21Web.JWTUtility do
  alias Guardian.Plug
  alias QuestApiV21.Accounts

  # Decodes the entire JWT token and logs its contents
  def decode_jwt(conn) do
    claims = Plug.current_claims(conn)
    # Uncomment to see decoded JWT token
    # IO.inspect(claims, label: "Decoded JWT Claims")
    claims
  end

  # Extracts the organization ID(s) from the JWT
  def get_organization_ids_from_jwt(conn) do
    claims = decode_jwt(conn)
    claims["organization_ids"] || []
  end

  # Extracts the primary organization ID for associating with a new record
  def extract_primary_organization_id_from_jwt(conn) do
    organization_ids = get_organization_ids_from_jwt(conn)
    List.first(organization_ids)
  end

  # Function to handle partner token verification and exchange
  def exchange_partner_token(partner_token) do
    with {:ok, partner_claims} <- verify_partner_token(partner_token),
         {:ok, account} <- find_or_create_account(partner_claims) do
      {:ok, jwt, _full_claims} = Guardian.encode_and_sign(account, %{})
      #IO.inspect(jwt, label: "Exchanged JWT")
      {:ok, jwt}
    else
      {:error, :invalid_token} ->
        #IO.puts("Exchange Partner Token: Invalid token")
        {:error, %{error: "Invalid token"}}
      {:error, :invalid_issuer} ->
        #IO.puts("Exchange Partner Token: Invalid issuer")
        {:error, %{error: "Invalid issuer"}}
      _ ->
        #IO.puts("Exchange Partner Token: Unknown error occurred")
        {:error, %{error: "Unknown error occurred"}}
    end
  end



  defp verify_partner_token(partner_token) do
    # For testing purposes, bypassing the secret key check
    case Guardian.decode_and_verify(partner_token, key: :partner_jwt_secret) do
      {:ok, claims} ->
        #IO.inspect(claims, label: "Decoded Claims")
        {:ok, claims} # Ignore issuer validation for testing

      {:error, reason} ->
        #IO.inspect(reason, label: "Decode/Verify Error")
        {:ok, %{"sub" => "test_subject"}} # For testing, return a dummy claim
    end
  end



  defp valid_issuer?(claims) do
    # Check the issuer of the token
    # Replace 'expected_issuer' with the actual issuer value you expect
    claims["iss"] == "expected_issuer"
  end

  # Function to find or create account based on partner token claims
  defp find_or_create_account(claims) do
    # Replace 'user_identifier_claim' with the actual claim key that identifies the user
    user_identifier = claims["sub"]
    IO.inspect(user_identifier, label: "User Identifier")

    case Accounts.get_user_by_identifier(user_identifier) do
      nil -> create_user(claims)
      account -> {:ok, account}
    end
  end

  # Function to create a user based on token claims
  defp create_user(claims) do
    email = claims["email"] || "default@email.com" # Provide a default email if not present
    name = claims["name"]
    # Other fields can be extracted similarly

    attrs = %{
      "email" => email,
      "name" => name,
      "is_passwordless" => true
    }

    Accounts.create_account(attrs)
  end
end
