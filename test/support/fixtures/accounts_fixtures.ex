defmodule QuestApiV21.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Accounts` context.
  """

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        email: "some email",
        hashed_passowrd: "some hashed_passowrd",
        name: "some name"
      })
      |> QuestApiV21.Accounts.create_account()

    account
  end
end
