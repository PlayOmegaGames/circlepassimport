defmodule QuestApiV21Web.HostAuthController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.{HostGuardian, Repo, Hosts.Host}
  alias QuestApiV21.Hosts

  # Function to handle host sign in
  def sign_in_host(conn, %{"host" => %{"email" => email, "password" => password}}) do
    case Repo.get_by(Host, email: email) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "host not found"})

      host ->
        if Bcrypt.verify_pass(password, host.hashed_password) do
          render_jwt_and_host(conn, host)
        else
          conn
          |> put_status(:unauthorized)
          |> json(%{error: "Incorrect password"})
        end
    end
  end

  # Function to handle host sign up
  def sign_up_host(conn, %{"host" => host_params}) do
    case Hosts.create_host(host_params) do
      {:ok, %Host{} = host} ->
        render_jwt_and_host(conn, host)

      {:error, error_message} when is_binary(error_message) ->
        conn
        |> put_status(:conflict)
        |> json(%{error: error_message})
    end
  end
  # Helper function to render JWT token and host information
  defp render_jwt_and_host(conn, host) do
    {:ok, jwt, _full_claims} = HostGuardian.encode_and_sign(host)
    conn
    |> put_status(:ok)
    |> put_resp_header("authorization", "Bearer #{jwt}")
    |> json(%{
      jwt: jwt,
      host: %{email: host.email, name: host.name, id: host.id}
    })
  end

  
end
