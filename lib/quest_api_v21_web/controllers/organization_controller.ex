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

  def create(conn, %{"organization" => organization_params}) do
    case extract_host_id(conn) do
      nil ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Unable to extract host ID from token"})

      host_id ->
        with {:ok, %Organization{} = organization} <- Organizations.create_organization(organization_params, host_id) do
          organization = QuestApiV21.Repo.preload(organization, [:hosts, :quests, :badges, :collectors])
          conn
          |> put_status(:created)
          |> put_resp_header("location", ~p"/api/organizations/#{organization.id}")
          |> render(:show, organization: organization)
        end
    end
  end


  defp extract_host_id(conn) do
    case Guardian.Plug.current_resource(conn) do
      nil -> nil
      host -> host.id
    end
  end

  def show(conn, %{"id" => id}) do
    organization = Organizations.get_organization!(id)
    |> QuestApiV21.Repo.preload([:hosts, :quests, :badges, :collectors])

    render(conn, :show, organization: organization)
  end

  def update(conn, %{"id" => id, "organization" => organization_params}) do
    organization = Organizations.get_organization!(id)

    with {:ok, %Organization{} = organization} <- Organizations.update_organization(organization, organization_params) do
      render(conn, :show, organization: organization)
    end
  end

  def delete(conn, %{"id" => id}) do
    organization = Organizations.get_organization!(id)

    with {:ok, %Organization{}} <- Organizations.delete_organization(organization) do
      send_resp(conn, :no_content, "")
    end
  end
end
