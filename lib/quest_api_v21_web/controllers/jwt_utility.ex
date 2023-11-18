defmodule QuestApiV21Web.JWTUtility do
  alias QuestApiV21.{HostGuardian, Repo}

  def get_organization_ids_from_jwt(conn) do
    claims = Guardian.Plug.current_claims(conn)
    claims["organization_ids"] || []
  end
end

