defmodule QuestApiV21.Repo do
  use Ecto.Repo,
    otp_app: :quest_api_v21,
    adapter: Ecto.Adapters.Postgres
end
