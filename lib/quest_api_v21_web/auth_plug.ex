defmodule QuestApiV21Web.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]
  alias QuestApiV21.Accounts
  require Logger

  def init(default), do: default

  def call(conn, _default) do
    user_id = get_session(conn, :user_id)
    request_path = conn.request_path

    # Logger.debug("AuthPlug called. User ID: #{inspect(user_id)}, Request Path: #{request_path}")

    # Regular expression to match /badge/ path
    badge_path_regex = ~r{/badge/.*}

    if user_id && Accounts.get_account!(user_id) do
      # Logger.debug("User authenticated. User ID: #{user_id}")
      assign_user(conn, user_id)
    else
      redirect_path =
        if Regex.match?(badge_path_regex, request_path), do: request_path, else: "/badges"

      Logger.debug("Redirect path set in session. Path: #{redirect_path}")

      conn
      |> put_session(:redirect_path, redirect_path)
      |> redirect(to: "/auth_splash")
      |> halt()
    end
  end

  defp assign_user(conn, user_id) do
    Logger.info("Session accessed for user_id: #{user_id}, at: #{DateTime.utc_now()}")
    assign(conn, :current_user, Accounts.get_account!(user_id))
  end
end
