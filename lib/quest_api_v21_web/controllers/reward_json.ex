defmodule QuestApiV21Web.RewardJSON do
  alias QuestApiV21.Accounts.Account
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Rewards.Reward

  def render("index.json", %{rewards: rewards}) do
    quests = Enum.group_by(rewards, fn %{quest: quest} -> quest.name end, &data/1)
    %{data: quests}
  end

  defp data(%Reward{quest: quest, account: account} = rewards) do
    %{
      id: rewards.id,
      redeemed: rewards.redeemed,
      created: rewards.inserted_at,
      account: account_data(account),
      quest: quest_data(quest)
    }
  end

  defp account_data(%Account{id: id, name: name, email: email, pfps: pfps}) do
    %{
      id: id,
      profile_picture: pfps,
      name: name,
      email: email
    }
  end

  defp quest_data(%Quest{id: id, name: name}) do
    %{
      id: id,
      name: name
    }
  end
end
