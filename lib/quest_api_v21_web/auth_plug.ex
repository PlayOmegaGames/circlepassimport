defmodule QuestApiV21Web.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]
  alias QuestApiV21.Accounts
  require Logger

  def init(default), do: default

  def call(conn, _default) do
    user_id = get_session(conn, :user_id)
    request_path = conn.request_path

    # Regular expression to match /badge/ path
    badge_path_regex = ~r{/badge/.*}

    if user_id && Accounts.get_account!(user_id) do
      assign_user(conn, user_id)
    else
      # Store the redirect path if request path matches /badge/
      conn = if Regex.match?(badge_path_regex, request_path), do: put_session(conn, :redirect_path, request_path), else: conn

      # Redirect all unauthenticated users to the sign-up page
      Logger.info("Redirecting unauthenticated user to sign-up: #{DateTime.utc_now()}")
      conn
      |> redirect(to: "/sign_up")
      |> halt()
    end
  end

  defp assign_user(conn, user_id) do
    Logger.info("Session accessed for user_id: #{user_id}, at: #{DateTime.utc_now()}")
    assign(conn, :current_user, Accounts.get_account!(user_id))
  end
end
