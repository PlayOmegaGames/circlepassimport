defmodule QuestApiV21Web.OrganizationController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Repo
  alias QuestApiV21.Organizations
  alias QuestApiV21.Organizations.Organization
  alias QuestApiV21Web.JWTUtility

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do

    host_id = JWTUtility.get_host_id_from_jwt(conn)

    case Organizations.list_organizations_by_host_id(host_id) do

      organizations ->
        organizations
        |> Repo.preload([:hosts, :quests, :badges, :collectors])

      render(conn, :index, organizations: organizations)
    end
  end

  def add_host(conn, %{"email" => host_email}) do
    organization_id = JWTUtility.get_organization_id_from_jwt(conn)

    case Organizations.associate_host_with_organization(host_email, organization_id) do
      {:ok, _organization} ->
        conn
        |> put_status(:ok)
        |> json(%{success: "account added to organization"})

      {:error, :host_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Host not found"})

      {:error, :organization_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Organization not found"})

      {:error, _changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Failed to add host to organization"})
    end
  end

  def create(conn, %{"organization" => organization_params}) do
    case extract_host_id(conn) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Host not found"})

      host_id ->
        case Organizations.create_organization(organization_params, host_id) do
          {:ok, organization, new_jwt} ->
            organization =
              QuestApiV21.Repo.preload(organization, [:hosts, :quests, :badges, :collectors])

            conn
            |> put_status(:created)
            |> put_resp_header("location", ~p"/api/organizations/#{organization.id}")
            |> render(:show, organization: organization, jwt: new_jwt)

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render("error.json", changeset: changeset)
        end
    end
  end

  defp extract_host_id(conn) do
    claims = Guardian.Plug.current_claims(conn)

    case claims do
      %{"sub" => host_id} -> host_id
      _ -> nil
    end
  end

  def show(conn, %{"id" => id}) do
    organization =
      Organizations.get_organization!(id)
      |> QuestApiV21.Repo.preload([:hosts])

    render(conn, :show, organization: organization)
  end

  def update(conn, %{"id" => id, "organization" => organization_params}) do
    organization = Organizations.get_organization!(id)

    with {:ok, %Organization{} = organization} <-
           Organizations.update_organization(organization, organization_params) do
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
