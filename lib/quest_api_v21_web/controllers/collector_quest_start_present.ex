defmodule QuestApiV21Web.CollectorQuestStartPresent do
  use QuestApiV21Web, :controller
  alias QuestApiV21.{Accounts, Quests}
  require Logger

  def handle_present_quest_start(conn, collector) do
    account = Accounts.get_account!(conn.assigns.current_user.id)

    # Fetch the quest based on quest_start field
    quest = Quests.get_quest(collector.quest_start)

    # Find the badge associated with both the collector and the quest
    badge = find_associated_badge(collector, quest)

    if badge do
      # Add badge and quest to account
      Accounts.add_badge_to_user(account.id, badge)
      Accounts.add_quest_to_user(account.id, quest)

      Logger.info("Added Badge ID: #{badge.id} and Quest ID: #{quest.id} to Account ID: #{account.id}")

      updated_account = Accounts.get_account!(account.id)
      Logger.info("Updated Account Record: #{inspect(updated_account)}")
    else
      Logger.error("No badge found associated with both Collector ID: #{collector.id} and Quest ID: #{quest.id}")
    end

    render(conn, "collector.html", collector: collector)
  end

  defp find_associated_badge(collector, quest) do
    collector.badges
    |> Enum.find(fn badge -> badge.quest_id == quest.id end)
  end
end
