defmodule QuestApiV21Web.QuestJSON do
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Badges.Badge
  alias QuestApiV21.Collectors.Collector

  #alias QuestApiV21.Organizations.Organization

  @doc """
  Renders a list of quests.
  """
  def index(%{quests: quests}) do
    %{data: for(quest <- quests, do: data(quest))}
  end

  @doc """
  Renders a single quest.
  """
  def show(%{quest: quest}) do
    %{data: data(quest)}
  end

  defp data(%Quest{badges: badges, collectors: collectors} = quest) do
    %{
      id: quest.id,
      name: quest.name,
      scans: quest.scans,
      quest_type: quest.quest_type,
      reward: quest.reward,
      redemption: quest.redemption,
      start_date: quest.start_date,
      end_date: quest.end_date,
      address: quest.address,
      orgaization_id: quest.orgaization_id,
      badges: badges_data(badges),
      collectors: collectors_data(collectors)

    }
  end

  defp collectors_data(collectors) do
    Enum.map(collectors, fn %Collector{id: id} ->
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

  """
  Useful for displaying more orgaization information

  defp orgaization_data(%Organization{} = orgaization) do
    %{
      id: orgaization.id,
      name: orgaization.name
    }
  end
  """

end
