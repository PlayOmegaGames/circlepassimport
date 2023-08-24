defmodule QuestApiV21.Collection_PointsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Collection_Points` context.
  """

  @doc """
  Generate a collection__point.
  """
  def collection__point_fixture(attrs \\ %{}) do
    {:ok, collection__point} =
      attrs
      |> Enum.into(%{
        badge_description: "some badge_description",
        image: "some image",
        name: "some name",
        redirect_url: "some redirect_url",
        scans: 42
      })
      |> QuestApiV21.Collection_Points.create_collection__point()

    collection__point
  end
end
