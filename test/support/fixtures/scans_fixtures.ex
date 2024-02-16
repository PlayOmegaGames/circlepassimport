defmodule QuestApiV21.ScansFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Scans` context.
  """

  @doc """
  Generate a scan.
  """
  def scan_fixture(attrs \\ %{}) do
    {:ok, scan} =
      attrs
      |> Enum.into(%{})
      |> QuestApiV21.Scans.create_scan()

    scan
  end
end
