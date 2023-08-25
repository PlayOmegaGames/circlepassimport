defmodule QuestApiV21.CollectorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Collectors` context.
  """

  @doc """
  Generate a collector.
  """
  def collector_fixture(attrs \\ %{}) do
    {:ok, collector} =
      attrs
      |> Enum.into(%{
        coordinates: "some coordinates",
        height: "some height",
        name: "some name"
      })
      |> QuestApiV21.Collectors.create_collector()

    collector
  end
end
