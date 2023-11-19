defmodule QuestApiV21.Guardian do
  use Guardian, otp_app: :quest_api_v21

  def subject_for_token(resource, _claims) do
    IO.inspect(resource, label: "Resource in subject_for_token")
    {:ok, to_string(resource.id)}
  end

  def resource_from_claims(claims) do
    {:ok, claims["sub"]}
  end

end
