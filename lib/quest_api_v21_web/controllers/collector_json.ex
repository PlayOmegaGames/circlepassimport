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

    @doc """
  Renders an error response.
  """
  def render("error.json", %{message: message}) do
    %{errors: %{detail: message}}
  end

  defp data(%Collector{badges: badges, quests: quests} = collector) do
    %{
      id: collector.id,
      name: collector.name,
      coordinates: collector.coordinates,
      height: collector.height,
      organization_id: collector.organization_id,
      quest_start: collector.quest_start,
      badges: badges_data(badges),
      quest_ids: quests_data(quests),
      qr_code_url: collector.qr_code_url
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
