# Defines the AccountController module within the QuestApiV21Web namespace.
defmodule QuestApiV21Web.AccountController do
  # Inherits functionality from QuestApiV21Web's controller module.
  use QuestApiV21Web, :controller

  # Aliases the QuestApiV21Web.Router.Helpers module as Routes for easier access.
  alias QuestApiV21Web.Router.Helpers, as: Routes

  # Aliases the QuestApiV21.Accounts and QuestApiV21.Accounts.Account modules for easier access.
  alias QuestApiV21.Accounts
  alias QuestApiV21.Accounts.Account

  # Specifies a fallback controller to handle errors.
  action_fallback QuestApiV21Web.FallbackController

  # Defines the index action to list all accounts.
  def index(conn, _params) do
    # Retrieves a list of accounts, preloading associated collection points.
    accounts = Accounts.list_accounts()
    |> QuestApiV21.Repo.preload(:collection_points)

    # Renders the index view with the list of accounts.
    render(conn, :index, accounts: accounts)
  end

  # Defines the create action to create a new account.
  def create(conn, %{"account" => account_params}) do
    # Attempts to create a new account with the provided parameters.
    case Accounts.create_account(account_params) do
      # Handles successful account creation.
      {:ok, %Account{} = account} ->
        # Preloads associated collection points for the new account.
        account = QuestApiV21.Repo.preload(account, [:collection_points])
        # Sets the response status to 201 Created, updates the location header,
        # and renders the show view for the new account.
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.account_path(conn, :show, account))
        |> render(:show, account: account)

      # Handles a conflict error when an account with the same email already exists.
      {:error, "An account with this email already exists", existing_account} ->
        # Sets the response status to 409 Conflict and returns a JSON error message.
        conn
        |> put_status(:conflict)
        |> json(%{error: "An account with this email already exists", existing_account: existing_account})

      # Handles other errors with the provided changeset.
      {:error, changeset} ->
        # Sets the response status to 422 Unprocessable Entity and renders an error JSON.
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end

  # Defines the show action to display a single account.
  def show(conn, %{"id" => id}) do
    # Retrieves the account by ID, preloading associated collection points.
    account = Accounts.get_account!(id)
    |> QuestApiV21.Repo.preload(:collection_points)

    # Renders the show view for the retrieved account.
    render(conn, :show, account: account)
  end

  # Defines the update action to update an existing account.
  def update(conn, %{"id" => id, "account" => account_params}) do
    # Retrieves the account by ID.
    account = Accounts.get_account!(id)

    # Attempts to update the account with the provided parameters.
    with {:ok, %Account{} = updated_account} <- Accounts.update_account(account, account_params) do
      # Renders the show view for the updated account.
      render(conn, :show, account: updated_account)
    end
  end

  # Defines the delete action to delete an existing account.
  def delete(conn, %{"id" => id}) do
    # Retrieves the account by ID.
    account = Accounts.get_account!(id)

    # Attempts to delete the account.
    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      # Sends a 204 No Content response upon successful deletion.
      send_resp(conn, :no_content, "")
    end
  end
end
