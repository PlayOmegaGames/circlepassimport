defmodule QuestApiV21.HostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Hosts` context.
  """

  @doc """
  Generate a host.
  """
  def host_fixture(attrs \\ %{}) do
    {:ok, host} =
      attrs
      |> Enum.into(%{
        email: "some email",
        hashed_password: "some hashed_password",
        name: "some name"
      })
      |> QuestApiV21.Hosts.create_host()

    host
  end
end
