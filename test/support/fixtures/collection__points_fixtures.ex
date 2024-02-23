defmodule QuestApiV21.BadgesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Badges` context.
  """

  @doc """
  Generate a badge.
  """
  def badge_fixture(attrs \\ %{}) do
    {:ok, badge} =
      attrs
      |> Enum.into(%{
        badge_description: "some badge_description",
        image: "some image",
        name: "some name",
        redirect_url: "some redirect_url",
        transactions: 42
      })
      |> QuestApiV21.Badges.create_badge()

    badge
  end
end
