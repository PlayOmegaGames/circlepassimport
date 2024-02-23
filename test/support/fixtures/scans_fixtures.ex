defmodule QuestApiV21.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Transactions` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{})
      |> QuestApiV21.Transactions.create_transaction()

    transaction
  end
end
