defmodule QuestApiV21.RewardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Rewards` context.
  """

  @doc """
  Generate a reward.
  """
  def reward_fixture(attrs \\ %{}) do
    {:ok, reward} =
      attrs
      |> Enum.into(%{
        public: true,
        reward_name: "some reward_name"
      })
      |> QuestApiV21.Rewards.create_reward()

    reward
  end
end
