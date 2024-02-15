defmodule QuestApiV21Web.SuperadminSessionController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Admin
  alias QuestApiV21Web.SuperadminAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:superadmin_return_to, ~p"/superadmin/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"superadmin" => superadmin_params}, info) do
    %{"email" => email, "password" => password} = superadmin_params

    if superadmin = Admin.get_superadmin_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> SuperadminAuth.log_in_superadmin(superadmin, superadmin_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/superadmin/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> SuperadminAuth.log_out_superadmin()
  end
end
