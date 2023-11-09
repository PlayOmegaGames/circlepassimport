defmodule QuestApiV21Web.CollectorJSON do
  alias QuestApiV21.Collectors.Collector
  alias QuestApiV21.Badges.Badge
  alias QuestApiV21.Quests.Quest

  @doc """
  Renders a list of collectors.
  """
  def index(%{collectors: collectors}) do
    %{data: for(collector <- collectors, do: data(collector))}
  end

  @doc """
  Renders a single collector.
  """
  def show(%{collector: collector}) do
    %{data: data(collector)}
  end

  defp data(%Collector{badges: badges, quests: quests} = collector) do
    %{
      id: collector.id,
      name: collector.name,
      coordinates: collector.coordinates,
      height: collector.height,
      badges: badges_data(badges),
      quest_ids: quests_data(quests)
    }
  end

  defp quests_data(quests) do
    Enum.map(quests, fn %Quest{id: id} ->
      %{
        id: id
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
end
