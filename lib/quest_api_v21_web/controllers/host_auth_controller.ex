defmodule QuestApiV21Web.HostAuthController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.{HostGuardian, Repo, Hosts.Host}
  alias QuestApiV21.Hosts

  def sign_in_host(conn, %{"host" => %{"email" => email, "password" => password}}) do
    case Repo.get_by(Host, email: email) |> Repo.preload(:organizations) do
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

  def sign_up_host(conn, %{"host" => host_params}) do
    case Hosts.create_host(host_params) do
      {:ok, host} ->
        render_jwt_and_host(conn, host)

      {:error, error_message} when is_binary(error_message) ->
        conn
        |> put_status(:conflict)
        |> json(%{error: error_message})
    end
  end

  defp render_jwt_and_host(conn, host) do
    case HostGuardian.encode_and_sign(host) do
      {:ok, jwt, _full_claims} ->
        host = QuestApiV21.Repo.preload(host, [:current_org])

        org_name = if host.current_org, do: host.current_org.name, else: ""

        conn
        |> put_status(:ok)
        |> put_resp_header("authorization", "Bearer #{jwt}")
        |> json(%{
          jwt: jwt,
          host: %{email: host.email, name: host.name, id: host.id, org_name: org_name}
        })

      {:error, reason} ->
        IO.inspect(reason, label: "Error in JWT encoding")

        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Internal server error"})
    end
  end
end
