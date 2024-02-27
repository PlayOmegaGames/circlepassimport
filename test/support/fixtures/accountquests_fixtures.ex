defmodule QuestApiV21.AccountquestsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Accountquests` context.
  """

  @doc """
  Generate a account_quest.
  """
  def account_quest_fixture(attrs \\ %{}) do
    {:ok, account_quest} =
      attrs
      |> Enum.into(%{
        badge_count: 42,
        loyalty_points: 42
      })
      |> QuestApiV21.Accountquests.create_account_quest()

    account_quest
  end
end
