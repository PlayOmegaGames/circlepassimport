defmodule QuestApiV21Web.TransactionController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Transactions
  alias QuestApiV21.Transactions.Transaction
  alias QuestApiV21Web.JWTUtility
  alias QuestApiV21.Repo

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    organization_id = JWTUtility.get_organization_id_from_jwt(conn)

    case Transactions.list_transactions_bg_organization_id(organization_id) do
      transactions ->
        transactions
        |> Repo.preload([:account, :badge])

        render(conn, :index, transactions: transactions)
    end
  end

  def create(conn, %{"transaction" => transaction_params}) do
    with {:ok, %Transaction{} = transaction} <-
           Transactions.create_transaction(transaction_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/transactions/#{transaction}")
      |> render(:show, transaction: transaction)
    end
  end

  def show(conn, %{"id" => id}) do
    transaction = Transactions.get_transaction!(id)
    render(conn, :show, transaction: transaction)
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = Transactions.get_transaction!(id)

    with {:ok, %Transaction{} = transaction} <-
           Transactions.update_transaction(transaction, transaction_params) do
      render(conn, :show, transaction: transaction)
    end
  end

  def delete(conn, %{"id" => id}) do
    transaction = Transactions.get_transaction!(id)

    with {:ok, %Transaction{}} <- Transactions.delete_transaction(transaction) do
      send_resp(conn, :no_content, "")
    end
  end
end
