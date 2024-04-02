defmodule QuestApiV21Web.OauthController do
  use QuestApiV21Web, :controller
  alias QuestApiV21.Accounts
  alias QuestApiV21Web.AccountAuth

  def callback(conn, %{"provider" => "google"} = _params) do
    case conn.assigns.ueberauth_auth do
      %Ueberauth.Auth{} = auth ->
        # Extract the necessary information from the Google OAuth response
        user_info = %{
          email: auth.info.email,
          name: auth.info.name,
          pfps: auth.info.image
        }

        # Handle user authentication or account creation based on the extracted information
        handle_user_auth(conn, user_info)

      _ ->
        # Handle authentication failure
        conn
        |> put_flash(:error, "Failed to authenticate with Google.")
        |> redirect(to: "/accounts/register")
    end
  end

  defp handle_user_auth(conn, %{email: email, name: name}) do
    case Accounts.handle_oauth_login(email, name) do
      {:ok, account, :new} ->
        AccountAuth.log_in_account(conn, account)
        |> put_flash(:info, "Successfully signed up and logged in.")
        |> redirect(to: "/home")

      {:ok, account, :existing} ->
        AccountAuth.log_in_account(conn, account)
        |> put_flash(:info, "Successfully logged in.")
        |> redirect(to: "/home")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Account creation or retrieval failed.")
        |> redirect(to: "/accounts/register")
    end
  end

  def request(_conn, _params) do
    # This will be handled by Ueberauth to redirect to Google
  end
end
