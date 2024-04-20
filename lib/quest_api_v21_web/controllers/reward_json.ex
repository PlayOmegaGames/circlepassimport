defmodule QuestApiV21Web.RewardJSON do
  alias QuestApiV21.Accounts.Account
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Rewards.Reward


  def render("index.json", %{rewards: rewards}) do
    %{data: for(rewards <- rewards, do: data(rewards))}
  end

  defp data(%Reward{quest: quest, account: account} = rewards) do
    %{
      id: rewards.id,
      account: account_data(account),
      quest: quest_data(quest)

    }
  end

  defp account_data(%Account{id: id, name: name, email: email}) do
    %{
      id: id,
      name: name,
      email: email
    }
  end

  defp quest_data(%Quest{id: id, name: name}) do
    %{
      id: id,
      name: name,
    }
  end
end
