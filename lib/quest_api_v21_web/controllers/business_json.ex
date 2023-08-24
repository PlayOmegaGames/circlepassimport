defmodule QuestApiV21Web.BusinessJSON do
  alias QuestApiV21.Businesses.Business
  alias QuestApiV21.Hosts.Host
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Collection_Points.Collection_Point

  @doc """
  Renders a list of businesses.
  """
  def index(%{businesses: businesses}) do
    %{data: for(business <- businesses, do: data(business))}
  end

  @doc """
  Renders a single business.
  """
  def show(%{business: business}) do
    %{data: data(business)}
  end

  defp data(%Business{hosts: hosts, quests: quests, collection_points: collection_points} = business) do
    %{
      id: business.id,
      name: business.name,
      hosts: hosts_data(hosts),
      quests: quests_data(quests),
      collection_points: collection_points_data(collection_points)
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

  defp collection_points_data(collection_points) do
    Enum.map(collection_points, fn %Collection_Point{id: id, name: name} ->
      %{
        id: id,
        name: name
      }
    end)
  end
end
