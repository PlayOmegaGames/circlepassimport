defmodule QuestApiV21Web.OrganizationJSON do
  alias QuestApiV21.Organizations.Organization
  alias QuestApiV21.Hosts.Host
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Badges.Badge
  alias QuestApiV21.Collectors.Collector

  @doc """
  Renders a list of organizations.
  """
  def index(%{organizations: organizations}) do
    %{data: for(organization <- organizations, do: data(organization))}
  end

  @doc """
  Renders a single organization.
  """
  def show(%{organization: organization}) do
    %{data: data(organization)}
  end

  defp data(%Organization{hosts: hosts, quests: quests, badges: badges, collectors: collectors} = organization) do
    %{
      id: organization.id,
      name: organization.name,
      hosts: hosts_data(hosts),
      quests: quests_data(quests),
      badges: badges_data(badges),
      collectors: collectors_data(collectors)
    }
  end

  defp hosts_data(hosts) do
    Enum.map(hosts, fn %Host{id: id, name: name, email: email} ->
      %{
        id: id,
        name: name,
        email: email
      }
    end)
  end

  defp quests_data(quests) do
    Enum.map(quests, fn %Quest{id: id, name: name} ->
      %{
        id: id,
        name: name
      }
    end)
  end

  defp badges_data(badges) do
    Enum.map(badges, fn %Badge{id: id, name: name} ->
      %{
        id: id,
        name: name
      }
    end)
  end

  defp collectors_data(collectors) do
    Enum.map(collectors, fn %Collector{id: id, name: name} ->
      %{
        id: id,
        name: name
      }
    end)
  end
end
