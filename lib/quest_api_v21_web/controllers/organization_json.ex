defmodule QuestApiV21Web.OrganizationJSON do
  alias QuestApiV21.Organizations.Organization
  alias QuestApiV21.Hosts.Host

  @doc """
  Renders a list of organizations.
  """
  def index(%{organizations: organizations}) do
    %{data: for(organization <- organizations, do: data(organization))}
  end

  def error(%{message: message}) do
    %{
      error: message
    }
  end

  @doc """
  Renders a changeset error.
  """
  def error(%{changeset: changeset}) do
    %{
      error: "Invalid data",
      details: changeset.errors |> Enum.map(fn {field, {message, _opts}} -> {field, message} end)
    }
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
      subscription_tier: organization.subscription_tier,
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
