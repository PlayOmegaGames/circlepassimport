defmodule QuestApiV21Web.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]
  alias QuestApiV21.Accounts

  def init(default), do: default
  def call(conn, _default) do
    user_id = get_session(conn, :user_id)
    case user_id do
      nil ->
        conn
        |> redirect(to: "/sign_in")
        |> halt()

      _user_id ->
        case Accounts.get_account!(user_id) do
          nil ->
            conn
            |> configure_session(drop: true)
            |> redirect(to: "/sign_in")
            |> halt()

          user ->
            assign(conn, :current_user, user)
        end
    end
  end
end
