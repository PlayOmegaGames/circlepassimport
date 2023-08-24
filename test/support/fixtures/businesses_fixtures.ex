defmodule QuestApiV21.BusinessesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Businesses` context.
  """

  @doc """
  Generate a business.
  """
  def business_fixture(attrs \\ %{}) do
    {:ok, business} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> QuestApiV21.Businesses.create_business()

    business
  end
end
