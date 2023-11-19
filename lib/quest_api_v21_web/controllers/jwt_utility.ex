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
      {:ok, jwt}
    else
      error -> {:error, error}
    end
  end

  # Function to verify partner token
  defp verify_partner_token(partner_token) do
    # Fetch the partner JWT secret key from the application config
    partner_jwt_secret = Application.get_env(:quest_api_v21, :partner_jwt_secret)

    with {:ok, claims} <- Guardian.decode_and_verify(partner_token, partner_jwt_secret),
         true <- valid_issuer?(claims) do
      {:ok, claims}
    else
      {:error, _reason} -> {:error, "Invalid token"}
      false -> {:error, "Invalid issuer"}
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
    user_identifier = claims["user_identifier_claim"]

    case Accounts.get_user_by_identifier(user_identifier) do
      nil -> create_user(claims)
      account -> {:ok, account}
    end
  end

  # Function to create a user based on token claims
  defp create_user(claims) do
    email = claims["email"]
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
