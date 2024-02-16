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
end
