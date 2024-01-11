# Defines the AccountController module within the QuestApiV21Web namespace.
defmodule QuestApiV21Web.AccountController do
  # Inherits functionality from QuestApiV21Web's controller module.
  use QuestApiV21Web, :controller

  # Aliases the QuestApiV21.Accounts and QuestApiV21.Accounts.Account modules for easier access.
  alias QuestApiV21.Accounts
  alias QuestApiV21.Accounts.Account
  alias QuestApiV21.Guardian

  require Logger

  plug :put_layout, {QuestApiV21Web.Layouts, "logged_in.html"}

  # Specifies a fallback controller to handle errors.
  action_fallback QuestApiV21Web.FallbackController


  # Defines the create action to create a new account.
  def create(conn, %{"account" => account_params}) do
    # Attempts to create a new account with the provided parameters.
    case Accounts.create_account(account_params) do
      # Handles successful account creation.
      {:ok, %Account{} = account} ->
        # Preloads associated collection points for the new account.
        account = QuestApiV21.Repo.preload(account, [:badges, :quests])
        # Sets the response status to 201 Created, updates the location header,
        # and renders the show view for the new account.
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/accounts/#{account.id}")
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
    |> QuestApiV21.Repo.preload([:badges, :quests])

    # Renders the show view for the retrieved account.
    render(conn, :show, account: account)
  end

  # Defines the update action to update an existing account.
  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)
            |> QuestApiV21.Repo.preload([:badges, :quests])

    with {:ok, %Account{} = updated_account} <- Accounts.update_account(account, account_params),
         {:ok, new_jwt, _full_claims} <- Guardian.encode_and_sign(updated_account) do
      updated_account = QuestApiV21.Repo.preload(updated_account, [:badges, :quests])
      conn
      |> put_status(:ok)
      |> render("account.json", account: updated_account, jwt: new_jwt)
    else
      # Handle update failure
      {:error, changeset} ->
        # Add your code here to handle changeset error
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end





  # Defines the delete action to delete an existing account.
  def delete(conn, %{"id" => id}) do
    # Retrieves the account by ID.
    account = Accounts.get_account!(id)
    |> QuestApiV21.Repo.preload([:badges, :quests])

    # Attempts to delete the account.
    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      # Sends a 204 No Content response upon successful deletion.
      send_resp(conn, :no_content, "")
    end
  end

  #Web

  def user_settings(conn, _params) do
    email = conn.assigns.current_user.email
    name = conn.assigns.current_user.name
    user_id = get_session(conn, :user_id)

    #IO.inspect(conn)

    render(conn, "user_settings.html", page_title: "Home", name: name, email: email, user_id: user_id)
  end

  def update_from_web(conn, %{"id" => id, "account" => account_params}) do
    email = conn.assigns.current_user.email
    name = conn.assigns.current_user.name
    user_id = get_session(conn, :user_id)
    account = Accounts.get_account!(id)
            |> QuestApiV21.Repo.preload([:badges, :quests])

    with {:ok, %Account{} = updated_account} <- Accounts.update_account(account, account_params) do
      updated_account = QuestApiV21.Repo.preload(updated_account, [:badges, :quests])
      conn
      |> put_flash(:info, "Account updated successfully.")
      |> render("user_settings.html",
        account: updated_account,
        name: name,
        email: email,
        page_title: "Home",
        user_id: user_id
        )
    else
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_flash(:error, "Error updating account.")
        |> render("user_settings.html",
          account: account,
          changeset: changeset,
          name: name,
          email: email,
          page_title: "Home",
          user_id: user_id
          )
    end
  end


end
