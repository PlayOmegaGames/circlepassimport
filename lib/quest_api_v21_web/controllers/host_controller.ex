defmodule QuestApiV21Web.HostController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Hosts
  alias QuestApiV21.Hosts.Host

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    hosts = Hosts.list_hosts()
    |> QuestApiV21.Repo.preload(:businesses)

    render(conn, :index, hosts: hosts)
  end

  def create(conn, %{"host" => host_params}) do
    with {:ok, %Host{} = host} <- Hosts.create_host(host_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/hosts/#{host}")
      |> render(:show, host: host)
    end
  end

  def show(conn, %{"id" => id}) do
    host = Hosts.get_host!(id)
    |> QuestApiV21.Repo.preload(:businesses)
    render(conn, :show, host: host)
  end

  def update(conn, %{"id" => id, "host" => host_params}) do
    host = Hosts.get_host!(id)

    with {:ok, %Host{} = host} <- Hosts.update_host(host, host_params) do
      render(conn, :show, host: host)
    end
  end

  def delete(conn, %{"id" => id}) do
    host = Hosts.get_host!(id)

    with {:ok, %Host{}} <- Hosts.delete_host(host) do
      send_resp(conn, :no_content, "")
    end
  end
end
