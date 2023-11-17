defmodule QuestApiV21.HostGuardianPipeline do
  use Guardian.Plug.Pipeline, otp_app: :quest_api_v21,
    module: QuestApiV21.HostGuardian,
    error_handler: QuestApiV21.GuardianErrorHandler

  # Use the same plugs as in GuardianPipeline, but they will now work with the HostGuardian module
  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
