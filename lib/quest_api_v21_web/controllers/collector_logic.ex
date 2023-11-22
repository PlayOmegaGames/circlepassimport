defmodule QuestApiV21Web.CollectorLogic do
  alias QuestApiV21.Accounts
  alias QuestApiV21.Collectors

  def process_quests_and_badges(collector, user, user_quests) do
    if collector.quest_start do
      handle_quest_actions(collector, user, user_quests)
    else
      log_no_quest_start(collector, user)
    end
  end

  defp handle_quest_actions(collector, user, user_quests) do
    unless has_quest?(user_quests, collector.quest_start) do
      add_quest_to_user(user, collector.quest_start)
      add_badge_to_user(user, collector)
    else
      IO.puts "User already has the quest"
    end
  end

  defp has_quest?(quests, quest_id), do: Enum.any?(quests, &(&1.id == quest_id))

  defp add_quest_to_user(user, quest_start) do
    Accounts.add_quest_to_user(user.id, quest_start)
    # Consider adding error handling and logging here.
  end

  defp add_badge_to_user(user, collector) do
    case Accounts.add_badge_to_user(user.id, Enum.at(collector.badges, 0)) do
      {:ok, _} -> IO.puts "Badge added successfully"
      {:error, reason} -> IO.inspect reason, label: "Failed to add badge"
    end
  end

  defp log_no_quest_start(collector, user) do
    IO.inspect user, label: "User at no quest start"
    IO.inspect collector, label: "Collector with no quest start"
  end
end
