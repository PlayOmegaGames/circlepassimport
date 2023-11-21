defmodule QuestApiV21Web.AuthController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.{Guardian, Repo, Accounts.Account}
  alias QuestApiV21.Accounts

  # API `sign_in` function for account authentication
  def sign_in(conn, %{"account" => %{"email" => email, "password" => password}}) do
    case Repo.get_by(Account, email: email) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Account not found"})

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

  # API `sign_up` function for account creation
  def sign_up(conn, %{"account" => account_params}) do
    case Accounts.create_account(account_params) do
      {:ok, %Account{} = account} ->
        render_jwt_and_account(conn, account)
      {:error, error_message, _existing_account} ->
        conn
        |> put_status(:conflict)
        |> json(%{error: error_message})
    end
  end

  # Helper function to render JWT and account information
  defp render_jwt_and_account(conn, account) do
    case Guardian.encode_and_sign(account) do
      {:ok, jwt, _full_claims} ->
        conn
        |> put_status(:ok)
        |> put_resp_header("authorization", "Bearer #{jwt}")
        |> json(%{
          jwt: jwt,
          account: %{email: account.email, name: account.name, id: account.id}
        })

      {:error, reason} ->
        IO.inspect(reason, label: "Error in JWT encoding")
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Internal server error"})
    end
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

    # Add HTML-Based Authentication Functions
    def html_sign_in(conn, %{"account" => %{"email" => email, "password" => password}}) do
      case Accounts.authenticate_user(email, password) do
        {:ok, account} ->
          conn
          |> put_session(:user_id, account.id)
          |> redirect(to: "/")

        {:error, :not_found} ->
          conn
          |> put_flash(:error, "Account not found")
          |> redirect(to: "/sign_in")

        {:error, :unauthorized} ->
          conn
          |> put_flash(:error, "Incorrect password")
          |> redirect(to: "/sign_in")
      end
    end


    def html_sign_up(conn, %{"account" => account_params}) do
      case Accounts.create_account(account_params) do
        {:ok, account} ->
          conn
          |> put_session(:account_id, account.id)
          |> redirect(to: "/")

        {:error, error_message, _existing_account} ->
          conn
          |> put_flash(:error, "Account creation failed: #{error_message}")
          |> redirect(to: "/sign_up")
      end
    end
    def html_sign_out(conn, _params) do
      conn
      |> configure_session(drop: true)
      |> redirect(to: "/")
    end

end
