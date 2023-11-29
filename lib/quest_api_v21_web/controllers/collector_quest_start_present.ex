defmodule QuestApiV21Web.CollectorQuestStartPresent do
  use QuestApiV21Web, :controller
  alias QuestApiV21.{Accounts, Quests}
  require Logger

  def handle_present_quest_start(conn, collector) do
    account = Accounts.get_account!(conn.assigns.current_user.id)
    quest = Quests.get_quest(collector.quest_start)
    badge = find_associated_badge(collector, quest)

    if badge do
      if Enum.any?(account.badges, fn b -> b.id == badge.id end) do
        Logger.info("User already has badge ID: #{badge.id}. No action taken.")
      else
        add_badge_and_create_scan(account, badge)
        add_quest_to_user(account, quest)
      end
    else
      Logger.error("No badge found associated with both Collector ID: #{collector.id} and Quest ID: #{quest.id}")
    end

    render(conn, "collector.html", collector: collector, badge: badge)
  end

  defp add_badge_and_create_scan(account, badge) do
    case Accounts.add_badge_to_user(account.id, badge) do
      {:ok, msg, _updated_account} ->
        Logger.info(msg)
        QuestApiV21.Scans.create_scan_for_badge_account(badge.id, account.id)
      {:error, reason} ->
        Logger.error("Failed to add badge: #{reason}")
    end
  end

  defp add_quest_to_user(account, quest) do
    case Accounts.add_quest_to_user(account.id, quest) do
      {:ok, msg, _updated_account} ->
        Logger.info(msg)
      {:error, reason} ->
        Logger.error("Failed to add quest: #{reason}")
    end
  end

  defp find_associated_badge(collector, quest) do
    collector.badges
    |> Enum.find(fn badge -> badge.quest_id == quest.id end)
  end
end
