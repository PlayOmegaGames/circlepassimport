defmodule QuestApiV21Web.JWTUtility do

  # Extracts the organization ID(s) from the JWT for filtering in context modules
  def get_organization_ids_from_jwt(conn) do
    claims = Guardian.Plug.current_claims(conn)
    claims["organization_ids"] || []
  end

  # Extracts the primary organization ID for associating with a new record
  def extract_primary_organization_id_from_jwt(conn) do
    get_organization_ids_from_jwt(conn)
    |> List.first()
  end
end
