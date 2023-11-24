defmodule QuestApiV21Web.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]
  alias QuestApiV21.Accounts
  require Logger

  def init(default), do: default

  def call(conn, _default) do
    user_id = get_session(conn, :user_id)
    case user_id do
      nil ->
        Logger.info("Access attempt without a session at: #{DateTime.utc_now()}")
        conn
        |> redirect(to: "/sign_in")
        |> halt()

      _user_id ->
        case Accounts.get_account!(user_id) do
          nil ->
            Logger.info("Invalid session detected, user not found for user_id: #{user_id}")
            conn
            |> configure_session(drop: true)
            |> redirect(to: "/sign_in")
            |> halt()

          user ->
            Logger.info("Session accessed for user: #{user.email}, ID: #{user.id}, at: #{DateTime.utc_now()}")
            assign(conn, :current_user, user)
        end
    end
  end
end
