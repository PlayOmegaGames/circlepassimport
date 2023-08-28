defmodule QuestApiV21Web.AccountController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Accounts
  alias QuestApiV21.Accounts.Account

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    |> QuestApiV21.Repo.preload(:collection_points)

    render(conn, :index, accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params) do
      account = QuestApiV21.Repo.preload(account, [:collection_points])
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/accounts/#{account}")
      |> render(:show, account: account)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    |> QuestApiV21.Repo.preload(:collection_points)

    render(conn, :show, account: account)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      render(conn, :show, account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end
end
