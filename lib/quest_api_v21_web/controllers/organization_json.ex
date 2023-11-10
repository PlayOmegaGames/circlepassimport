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
    %{data: for(orgaization <- organizations, do: data(orgaization))}
  end

  @doc """
  Renders a single orgaization.
  """
  def show(%{orgaization: orgaization}) do
    %{data: data(orgaization)}
  end

  defp data(%Organization{hosts: hosts, quests: quests, badges: badges, collectors: collectors} = orgaization) do
    %{
      id: orgaization.id,
      name: orgaization.name,
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
