  defmodule QuestApiV21Web.AuthController do
    use QuestApiV21Web, :controller

    alias QuestApiV21.{Guardian, Repo, Accounts.Account}
    alias QuestApiV21.Accounts
    require Logger
    plug Ueberauth


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



    # API `change_email` function for password authentication
    def change_email(conn, %{"account" => %{"email" => email, "password" => password}}) do

      account = conn.assigns[:current_user]
      IO.inspect(account.id)
      case Accounts.authenticate_user_by_id(email, account.id, password) do
        {:ok, account} ->

          with {:ok, %Account{} = updated_account} <- Accounts.update_account(account, %{"email" => email, "password" => password}) do
            updated_account = QuestApiV21.Repo.preload(updated_account, [:badges, :quests])
            conn
            #|> put_flash(:info, "Account updated successfully.")
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
          #|> put_flash(:info, "Successfully changed email.")
          |> put_session(:user_id, account.id)
          |> put_session(:user_email, account.email)
          |> log_session_info()
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

    # API `sign_up` function for account creation
    def sign_up(conn, %{"account" => account_params}) do
      case Accounts.create_account(account_params) do
        {:ok, %Account{} = account} ->
          render_jwt_and_account(conn, account)

        {:error, :email_taken} ->
          conn
          |> put_status(:conflict)
          |> json(%{error: "Email already in use"})
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
          #|> put_flash(:info, "Successfully signed in.")
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

    # Change Email Authentication Functions
    def change_email_sign_in(conn, %{"account" => %{"email" => email, "password" => password}}) do
      case Accounts.authenticate_user(email, password) do
        {:ok, account} ->
          redirect_path = get_session(conn, :redirect_path) || "/badges"
          Logger.debug("Sign in successful. Redirecting to: #{redirect_path}")
          conn
          #|> put_flash(:info, "Successfully signed in.")
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
          Logger.debug("Sign up successful. Redirecting to: #{redirect_path}")

          conn
          #|> put_flash(:info, "Account successfully created.")
          |> put_session(:user_id, account.id) # Ensure this matches the key expected by AuthPlug
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


      # Function to initiate OAuth flow
    def request(_conn, _params) do
      # This will be handled by Ueberauth to redirect to Google
    end

    # Function to handle OAuth callback
    def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
      user_info = auth.info
      email = user_info.email
      name = user_info.name
      Logger.debug("Extracted email: #{inspect(email)}")

      case Accounts.handle_oauth_login(email, name) do
        {:ok, account, :new} ->
          # If a new account is created, handle accordingly.
          Logger.info("New OAuth account created for #{email}")

          # Set a flash message to indicate successful account creation.
          conn
          #|> put_flash(:info, "Account created and signed in with Google.")

          # Store user ID in the session for the newly created account.
          |> put_session(:user_id, account.id)

          # Redirect to the badges page after successful sign-up.
          |> redirect(to: "/badges")

        {:ok, account, :existing} ->
          # If an existing account is found, handle the login.
          Logger.info("Existing user found for #{email}, signing in")

          # Set a flash message to indicate successful sign-in.
          conn
          #|> put_flash(:info, "Successfully signed in with Google.")

          # Store user ID in the session for the existing account.
          |> put_session(:user_id, account.id)

          # Redirect to the badges page after successful sign-in.
          |> redirect(to: "/badges")

        {:error, reason} ->
          # If there is an error during account retrieval or creation, handle it.
          Logger.error("Error during Google authentication: #{reason}")

          # Set a flash message to indicate the authentication error.
          conn
          |> put_flash(:error, "Authentication failed: #{reason}")

          # Redirect to an appropriate error page or splash page.
          |> redirect(to: "/auth_splash")
      end
    end


    def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
      Logger.error("Google OAuth failure: #{inspect(failure)}")
      conn
      |> put_flash(:error, "Authentication failed")
      |> redirect(to: "/sign_in")
    end
  end
