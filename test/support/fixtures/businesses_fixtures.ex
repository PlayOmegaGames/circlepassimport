defmodule QuestApiV21.OrganizationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Organizations` context.
  """

  @doc """
  Generate a organization.
  """
  def organization_fixture(attrs \\ %{}) do
    {:ok, organization} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> QuestApiV21.Organizations.create_organization()

    organization
  end
end
