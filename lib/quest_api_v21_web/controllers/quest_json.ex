defmodule QuestApiV21Web.QuestJSON do
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Businesses.Business

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

  defp data(%Quest{} = quest) do
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
      business_id: quest.business_id
    }
  end

  """
  Useful for displaying more business information

  defp business_data(%Business{} = business) do
    %{
      id: business.id,
      name: business.name
    }
  end
  """

end
