defmodule QuestApiV21Web.AuthController do
  use QuestApiV21Web, :controller  # Inherits from the Phoenix controller module

  alias QuestApiV21.{Guardian, Repo, Accounts.Account}  # Shortens module names for easier reference
  alias QuestApiV21.Accounts

  # `sign_in` function to handle account authentication
  def sign_in(conn, %{"account" => %{"email" => email, "password" => password, }}) do
    case Repo.get_by(Account, email: email) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "account not found"})

      account ->
        if Bcrypt.verify_pass(password, account.hashed_password) do
          render_jwt_and_account(conn, account)
        else
          conn
          |> put_status(:unauthorized)
          |> json(%{error: "Incorrect password"})
        end
    end
  end

  # `sign_up` function to handle account creation
  def sign_up(conn, %{"account" => account_params}) do
    case Accounts.create_account(account_params) do
      {:ok, %Account{} = account} ->
        render_jwt_and_account(conn, account)
      {:error, error_message, _existing_account} ->
        conn
        |> put_status(:conflict)  # 409 Conflict
        |> render("sign_up_error.json", error: error_message)
    end
  end

  defp render_jwt_and_account(conn, account) do
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(account)
    conn
    |> put_status(:ok)
    |> put_resp_header("authorization", "Bearer #{jwt}")
    |> json(%{jwt: jwt, account: %{email: account.email, name: account.name, id: account.id}})
  end

  #token exchange
  def token_exchange(conn, %{"token" => partner_token}) when not is_nil(partner_token) do
    case QuestApiV21Web.JWTUtility.exchange_partner_token(partner_token) do
      {:ok, jwt} ->
        conn
        |> put_status(:ok)
        |> json(%{jwt: jwt})

      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: reason})  # Ensure 'reason' is a string or map that can be converted to JSON
    end
  end

  def token_exchange(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Token not provided or invalid format"})
  end
end
