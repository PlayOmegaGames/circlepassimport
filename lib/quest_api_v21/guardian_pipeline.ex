defmodule QuestApiV21.GuardianPipeline do
  use Guardian.Plug.Pipeline, otp_app: :quest_api_v21,
    module: QuestApiV21.Guardian,
    error_handler: QuestApiV21.GuardianErrorHandler

#  @claims %{iss: "YourAppIssuer"}

 # plug Guardian.Plug.VerifySession, claims: @claims  # If you are using sessions
 # plug Guardian.Plug.VerifyHeader, claims: @claims, scheme: "Bearer"
  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
