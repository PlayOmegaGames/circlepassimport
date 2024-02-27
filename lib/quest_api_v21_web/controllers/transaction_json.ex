defmodule QuestApiV21Web.TransactionJSON do
  alias QuestApiV21.Transactions.Transaction

  @doc """
  Renders a list of transactions.
  """
  def index(%{transactions: transactions}) do
    %{data: for(transaction <- transactions, do: data(transaction))}
  end

  @doc """
  Renders a single transaction.
  """
  def show(%{transaction: transaction}) do
    %{data: data(transaction)}
  end

  @doc """
  Renders an error response.
  """
  def render("error.json", %{message: message}) do
    %{errors: %{detail: message}}
  end

  defp data(%Transaction{} = transaction) do
    %{
      id: transaction.id,
      organization_id: transaction.organization_id,
      account_id: transaction.account_id,
      badge_id: transaction.badge_id
    }
  end
end
