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

  defp data(%Transaction{account: account, badge: badge} = transaction) do
    %{
      account_email: account.email,
      account_name: account.name,
      badge_name: badge.name,
      badge_id: badge.id,
      quest_id: badge.quest_id,
      time: transaction.inserted_at
    }
  end
end
