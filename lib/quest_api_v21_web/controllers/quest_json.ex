defmodule QuestApiV21Web.QuestJSON do
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Badges.Badge
  alias QuestApiV21.Collectors.Collector
  #alias QuestApiV21.Accounts.Account


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

  def error(%{message: message}) do
    %{
      error: message
    }
  end

    @doc """
  Renders an error response.
  """
  def render("error.json", %{message: message}) do
    %{errors: %{detail: message}}
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
      organization_id: quest.organization_id,
      description: quest.description,
      discount_code: quest.discount_code,
      public: quest.public,
      quest_time: quest.quest_time,
      badges: badges_data(badges),
      collectors: collectors_data(collectors),
      #accounts: accounts_data(accounts)
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

end
