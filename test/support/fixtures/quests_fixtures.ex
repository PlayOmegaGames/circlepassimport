defmodule QuestApiV21.QuestsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Quests` context.
  """

  @doc """
  Generate a quest.
  """
  def quest_fixture(attrs \\ %{}) do
    {:ok, quest} =
      attrs
      |> Enum.into(%{
        address: "some address",
        end-date: ~D[2023-08-23],
        name: "some name",
        quest-type: "some quest-type",
        redemption: "some redemption",
        reward: "some reward",
        scans: 42,
        start-date: ~D[2023-08-23]
      })
      |> QuestApiV21.Quests.create_quest()

    quest
  end
end
