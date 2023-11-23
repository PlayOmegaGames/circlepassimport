defmodule QuestApiV21Web.CollectorQuestStartPresent do
  use QuestApiV21Web, :controller
  alias QuestApiV21.{Accounts, Quests}
  require Logger

  def handle_present_quest_start(conn, collector) do
    account = Accounts.get_account!(conn.assigns.current_user.id)
    quest = Quests.get_quest(collector.quest_start)
    badge = find_associated_badge(collector, quest)

    if badge do
      case Accounts.add_badge_to_user(account.id, badge) do
        {:ok, msg, _updated_account} ->
          Logger.info(msg)
        {:error, reason} ->
          Logger.error("Failed to add badge: #{reason}")
      end

      case Accounts.add_quest_to_user(account.id, quest) do
        {:ok, msg, _updated_account} ->
          Logger.info(msg)
        {:error, reason} ->
          Logger.error("Failed to add quest: #{reason}")
      end


      #updated_account = Accounts.get_account!(account.id)
      #Logger.info("Updated Account Record: #{inspect(updated_account)}")
    else
      Logger.error("No badge found associated with both Collector ID: #{collector.id} and Quest ID: #{quest.id}")
    end

    render(conn, "collector.html", collector: collector, badge: badge)
  end

  defp find_associated_badge(collector, quest) do
    collector.badges
    |> Enum.find(fn badge -> badge.quest_id == quest.id end)
  end
end
