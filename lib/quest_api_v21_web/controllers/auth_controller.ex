  defmodule QuestApiV21Web.AuthController do
    use QuestApiV21Web, :controller

    alias QuestApiV21.{Guardian, Repo, Accounts.Account}
    alias QuestApiV21.Accounts
    require Logger

    # API `sign_in` function for account authentication
    def sign_in(conn, %{"account" => %{"email" => email, "password" => password}}) do
      case Repo.get_by(Account, email: email) do
        nil ->
          Logger.info("Sign in attempt failed: Account not found for #{email}")
          conn
          |> put_status(:not_found)
          |> json(%{error: "Account not found"})


        account ->
          if Bcrypt.verify_pass(password, account.hashed_password) do
            Logger.info("User signed in: #{email}, at: #{DateTime.utc_now()}")
            # Log additional session information if necessary
            render_jwt_and_account(conn, account)
          else
            Logger.info("Sign in attempt failed: Incorrect password for #{email}")
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


    # Add HTML-Based Authentication Functions
    def html_sign_in(conn, %{"account" => %{"email" => email, "password" => password}}) do
      case Accounts.authenticate_user(email, password) do
        {:ok, account} ->
          redirect_path = get_session(conn, :redirect_path) || "/badges"
          Logger.debug("Sign in successful. Redirecting to: #{redirect_path}")
          conn
          |> put_flash(:info, "Successfully signed in.")
          |> put_session(:user_id, account.id)
          |> put_session(:user_email, account.email)
          |> log_session_info()
          |> redirect(to: redirect_path)


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
          redirect_path = get_session(conn, :redirect_path) || "/badges"
          conn
          |> put_flash(:info, "Account successfully created.")
          |> put_session(:account_id, account.id)
          |> put_session(:redirect_path, nil) # Clear the stored redirect path
          |> redirect(to: redirect_path)

        {:error, error_message, _existing_account} ->
          conn
          |> put_flash(:error, "Account creation failed: #{error_message}")
          |> redirect(to: "/sign_up")
      end
    end


    def html_sign_out(conn, _params) do
      conn
      |> configure_session(drop: true)
      |> redirect(to: "/sign_in")
    end


    defp log_session_info(conn) do
      Logger.info("Session set for user: #{inspect(get_session(conn, :user_email))}")
      conn
    end

  end
