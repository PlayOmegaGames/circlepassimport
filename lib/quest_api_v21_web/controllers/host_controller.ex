defmodule QuestApiV21Web.HostController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Hosts
  alias QuestApiV21.Hosts.Host

  action_fallback QuestApiV21Web.FallbackController

  def create(conn, %{"host" => host_params}) do
    case Hosts.create_host(host_params) do
      {:ok, %Host{} = host} ->
        host = QuestApiV21.Repo.preload(host, [:organizations])

        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/hosts/#{host.id}")
        |> render(:show, host: host)

      {:error, "A host with this email already exists", existing_host} ->
        conn
        |> put_status(:conflict)
        |> json(%{error: "A host with this email already exists", existing_host: existing_host})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    host =
      Hosts.get_host!(id)
      |> QuestApiV21.Repo.preload(:organizations)

    render(conn, :show, host: host)
  end

  def update(conn, %{"id" => id, "host" => host_params}) do
    host = Hosts.get_host!(id)

    with {:ok, %Host{} = updated_host} <- Hosts.update_host(host, host_params) do
      updated_host = QuestApiV21.Repo.preload(updated_host, [:organizations])
      render(conn, :show, host: updated_host)
    end
  end

  def delete(conn, %{"id" => id}) do
    host = Hosts.get_host!(id)

    with {:ok, %Host{}} <- Hosts.delete_host(host) do
      send_resp(conn, :no_content, "")
    end
  end

  #Change current_org
  def change_org(conn, %{"organization_id" => org_id}) do
    host_id = QuestApiV21Web.JWTUtility.decode_jwt(conn)["sub"]

    case QuestApiV21.Hosts.get_host!(host_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Host not found"})
      host ->
        case QuestApiV21.Hosts.is_organization_associated_with_host?(host.id, org_id) do
          true ->
            case QuestApiV21.Hosts.update_current_org(host, org_id) do
              {:ok, updated_host} ->
                case QuestApiV21.HostGuardian.regenerate_jwt_for_host(updated_host) do
                  {:ok, token, _claims} ->
                    conn
                    |> put_status(:ok)
                    |> json(%{
                      message: "Current organization updated successfully",
                      jwt_token: token
                    })
                  {:error, reason} ->
                    conn
                    |> put_status(:unprocessable_entity)
                    |> json(%{error: "JWT token could not be regenerated: #{reason}"})
                end
              {:error, _reason} ->
                conn
                |> put_status(:unprocessable_entity)
                |> json(%{error: "Could not update the current organization"})
            end
          false ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Invalid organization ID or not associated with the host"})
        end
    end
  end

end
