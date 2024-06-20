defmodule QuestApiV21Web.OrganizationJSON do
  alias QuestApiV21.Organizations.Organization
  alias QuestApiV21.Hosts.Host

  @doc """
  Renders a list of organizations.
  """
  def index(%{organizations: organizations}) do
    %{data: for(organization <- organizations, do: data(organization))}
  end

  @doc """
  Renders a single organization.
  """
  def show(%{organization: organization, jwt: jwt}) do
    %{data: data(organization), jwt: jwt}
  end

  # Adjusted data function to include only id, name, and hosts for an organization
  defp data(%Organization{hosts: hosts} = organization) do
    %{
      id: organization.id,
      name: organization.name,
      inserted_at: organization.inserted_at,
      hosts: hosts_data(hosts)
    }
  end

  # Provided hosts_data function remains to handle hosts details
  defp hosts_data(hosts) do
    Enum.map(hosts, fn %Host{id: id, name: name} ->
      %{
        id: id,
        org_name: name
      }
    end)
  end
end
