defmodule QuestApiV21Web.OrganizationController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Organizations
  alias QuestApiV21.Organizations.Organization

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    organizations = Organizations.list_organizations()
    |> QuestApiV21.Repo.preload([:hosts, :quests, :badges, :collectors])


    render(conn, :index, organizations: organizations)
  end

  def create(conn, %{"orgaization" => orgaization_params}) do
    with {:ok, %Organization{} = orgaization} <- Organizations.create_orgaization(orgaization_params) do
      orgaization = QuestApiV21.Repo.preload(orgaization, [:hosts, :quests, :badges, :collectors])
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/organizations/#{orgaization}")
      |> render(:show, orgaization: orgaization)
    end
  end

  def show(conn, %{"id" => id}) do
    orgaization = Organizations.get_orgaization!(id)
    |> QuestApiV21.Repo.preload([:hosts, :quests, :badges, :collectors])

    render(conn, :show, orgaization: orgaization)
  end

  def update(conn, %{"id" => id, "orgaization" => orgaization_params}) do
    orgaization = Organizations.get_orgaization!(id)

    with {:ok, %Organization{} = orgaization} <- Organizations.update_orgaization(orgaization, orgaization_params) do
      render(conn, :show, orgaization: orgaization)
    end
  end

  def delete(conn, %{"id" => id}) do
    orgaization = Organizations.get_orgaization!(id)

    with {:ok, %Organization{}} <- Organizations.delete_orgaization(orgaization) do
      send_resp(conn, :no_content, "")
    end
  end
end
