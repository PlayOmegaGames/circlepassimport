defmodule QuestApiV21Web.JWTUtility do
  alias Guardian.Plug

  #IMPORTANT
  #When test make sure you test with a new regenerated token, otherwise you will not see your changes

  # Decodes the entire JWT token and logs its contents
  def decode_jwt(conn) do
    claims = Plug.current_claims(conn)
    # Uncomment to see decoded JWT token
    IO.inspect(claims, label: "Decoded JWT Claims")
    claims
  end

  # Extracts the organization ID(s) from the JWT
  def get_organization_id_from_jwt(conn) do
    claims = decode_jwt(conn)
    claims["organization_id"]
  end

  # Extracts the primary organization ID for associating with a new record
  def extract_organization_id_from_jwt(conn) do
    organization_id = get_organization_id_from_jwt(conn)
    organization_id
  end
end
