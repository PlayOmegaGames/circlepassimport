defmodule QuestApiV21.GuardianPipeline do
  use Guardian.Plug.Pipeline, otp_app: :quest_api_v21, module: QuestApiV21.Guardian

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.LoadResource
  plug Guardian.Plug.EnsureAuthenticated, error_handler: QuestApiV21.GuardianErrorHandler
end
