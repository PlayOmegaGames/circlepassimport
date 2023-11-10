defmodule QuestApiV21.OrganizationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Organizations` context.
  """

  @doc """
  Generate a orgaization.
  """
  def orgaization_fixture(attrs \\ %{}) do
    {:ok, orgaization} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> QuestApiV21.Organizations.create_orgaization()

    orgaization
  end
end
