defmodule QuestApiV21Web.RewardController do
  use QuestApiV21Web, :controller
  alias QuestApiV21.Rewards
  alias QuestApiV21.Rewards
  alias QuestApiV21Web.JWTUtility

  def redeem(conn, %{"slug" => slug}) do
    organization_id = JWTUtility.extract_organization_id_from_jwt(conn)

    case Rewards.redeem_reward_by_slug(organization_id, slug) do
      {:ok, _reward} ->
        conn
        # This line is technically optional as 200 is the default
        |> put_status(200)
        |> json(%{message: "Reward has been successfully redeemed!"})

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> json(%{error: "Reward not found or does not belong to the organization."})

      {:error, :already_redeemed} ->
        conn
        |> put_status(400)
        |> json(%{error: "This reward has already been redeemed."})

      {:error, _reason} ->
        conn
        |> put_status(500)
        |> json(%{error: "Unable to redeem the reward at this time."})
    end
  end
end
