defmodule QuestApiV21.Guardian do
  use Guardian, otp_app: :quest_api_v21

  # This function adds the role to the JWT claims
  def subject_for_token(resource, _claims) do
    # Create a subject with both the ID and the role
    sub = to_string(resource.id) <> "|" <> to_string(resource.role)
    {:ok, sub}
  end

  # This function retrieves the resource from the database based on the claims
  def resource_from_claims(claims) do
    # Split the subject to extract the ID and role
    [id, role] = String.split(claims["sub"], "|")

    # Fetch the resource from the database using the ID and role
    resource = QuestApiV21.Accounts.get_user_by_role_and_id(role, id)

    # You'll need to implement the `get_user_by_role_and_id/2` function in your accounts context
    {:ok, resource}
  end
end
