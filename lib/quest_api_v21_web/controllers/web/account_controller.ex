defmodule QuestApiV21Web.Web.AccountController do

  use QuestApiV21Web, :controller
  alias QuestApiV21.Accounts
  alias QuestApiV21.Accounts.Account
  require Logger
  plug :put_layout, html: {QuestApiV21Web.Layouts, :logged_in}


  def user_settings(conn, _params) do
    account = conn.assigns[:current_user]
    #IO.inspect(conn)
    render(conn, "user_settings.html", page_title: "Home", account: account)
  end

  def update_from_web(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)
            |> QuestApiV21.Repo.preload([:badges, :quests])

    with {:ok, %Account{} = updated_account} <- Accounts.update_account(account, account_params) do
      updated_account = QuestApiV21.Repo.preload(updated_account, [:badges, :quests])
      conn
      |> put_flash(:info, "Account updated successfully.")
      |> render("user_settings.html", account: updated_account, page_title: "Home"
      )
    else
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_flash(:error, "Error updating account.")
        |> render("user_settings.html", account: account, changeset: changeset, page_title: "Home")
    end
  end


  # API `change_email` function for password authentication
  def change_email(conn, %{"account" => %{"email" => email, "password" => password}}) do

    account = conn.assigns[:current_user]
    #IO.inspect(account.id)
    case Accounts.authenticate_user_by_id(email, account.id, password) do
      {:ok, account} ->

        with {:ok, %Account{} = updated_account} <- Accounts.update_account(account, %{"email" => email, "password" => password}) do
          updated_account = QuestApiV21.Repo.preload(updated_account, [:badges, :quests])
          conn
          |> put_flash(:info, "Account updated successfully.")
          |> render("user_settings.html",
            account: updated_account,
            email: email,
            page_title: "Home"
            )
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_flash(:error, "Error updating account.")
            |> render("user_settings.html",
              account: account,
              changeset: changeset,
              email: email,
              page_title: "Home"
              )
          end

        redirect_path = get_session(conn, :redirect_path) || "/user-settings"
        Logger.debug("Email change successful. Redirecting to: #{redirect_path}")
        conn
        |> put_flash(:info, "Successfully changed email.")
        |> put_session(:user_id, account.id)
        |> put_session(:user_email, account.email)
        |> redirect(to: redirect_path)


      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Incorrect password")
        |> redirect(to: "/sign_in")

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "Incorrect password")
        |> redirect(to: "/sign_in")
    end
  end

  # API `change_password` function for password authentication
  def change_password(conn, params) do
    current_password = params["current_password"]
    new_password = params["password"]
    confirmation_password = params["confirmation_password"]
    if new_password == confirmation_password do
      account = conn.assigns[:current_user]
      #IO.inspect(account.id)
      case Accounts.authenticate_user_by_password(account.email, account.id, current_password) do
        {:ok, account} ->

        with {:ok, %Account{} = updated_account} <- Accounts.update_account(account, %{"password" => new_password}) do
          updated_account = QuestApiV21.Repo.preload(updated_account, [:badges, :quests])
          conn
          |> put_flash(:info, "Account updated successfully.")
          |> render("user_settings.html",
            account: updated_account,
            password: account.password,
            page_title: "User Settings"
            )
        else
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_flash(:error, "Error updating account.")
            |> render("user_settings.html",
              account: account,
              changeset: changeset,
              password: account.password,
              page_title: "User Settings"
              )
          end

          redirect_path = get_session(conn, :redirect_path) || "/user-settings"
          #Logger.debug("Password change successful. Redirecting to: #{redirect_path}")
          conn
          |> put_flash(:info, "Successfully changed password.")
          |> put_session(:user_id, account.id)
          |> put_session(:user_email, account.email)
          |> redirect(to: redirect_path)


        {:error, :not_found} ->
        conn
        |> put_flash(:error, "Incorrect password")
        |> redirect(to: "/user-settings")

        {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "Incorrect password")
        |> redirect(to: "/user-settings")
    end
    else
      conn
        |> put_flash(:error, "Passwords do not match")
        |> redirect(to: "/user-settings")
    end
  end
end
