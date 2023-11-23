defmodule QuestApiV21Web.CollectorQuestStartNil do
  use QuestApiV21Web, :controller
  alias QuestApiV21.{Accounts, Badges}
  require Logger

  def handle_nil_quest_start(conn, collector) do
    current_account = conn.assigns[:current_user]

    # Compare quests between collector and account
    common_quests_ids = compare_quests(collector, current_account)

    # Check if there are common quests
    if Enum.empty?(common_quests_ids) do
      # No common quests, render no_quest.html and return
      Logger.info("No quests in common, rendering no_quest.html")
      render(conn, "no_quest.html", collector: collector)
    else
      # If there are common quests, proceed with badge logic
      common_badges = compare_badges(collector)

      # Check if there are common badges before proceeding
      if Enum.empty?(common_badges) do
        # No common badges, render a suitable template or take appropriate action
        Logger.info("No common badges, rendering a suitable template")
        # ... Render appropriate template or take action ...
      else
        add_common_badges_to_account(common_badges, current_account)

        # Fetch badge details if common_badge is not nil
        common_badge = common_badges |> List.first()
        badge = if common_badge, do: Badges.get_badge!(common_badge), else: nil

        # Pass badge to the template if it exists
        render(conn, "collector.html", collector: collector, badge: badge)
      end
    end
  end


  #finds the quests in common between the collector and quest
  defp compare_quests(collector, account) do
    collector_quests_ids = Enum.map(collector.quests, & &1.id)
    account_quests_ids = Enum.map(account.quests, & &1.id)

    common_quests_ids = collector_quests_ids |> Enum.filter(&Enum.member?(account_quests_ids, &1))

    log_common_quests(common_quests_ids, collector.id, account.id)
  end

  defp log_common_quests([], collector_id, account_id) do
    Logger.info("Collector #{collector_id} and account #{account_id} have no quests in common")
  end
  defp log_common_quests(common_quests, collector_id, account_id) do
    Logger.info("Collector #{collector_id} and account #{account_id} share quests: #{inspect(common_quests)}")
  end

  #finds the badges in common between the quest and the collector
  defp compare_badges(collector) do
    # Log the badge IDs associated directly with the collector
    collector_badges = Enum.map(collector.badges, & &1.id)
    Logger.debug("Collector badges: #{inspect(collector_badges)}")

    # Log the badge IDs associated with the quests of the collector
    quest_badges = collector.quests |> Enum.flat_map(& &1.badges) |> Enum.map(& &1.id)
    Logger.debug("Quest badges: #{inspect(quest_badges)}")

    # Determine common badges and log them
    common_badges = Enum.filter(quest_badges, &Enum.member?(collector_badges, &1))
    Logger.debug("Common badges: #{inspect(common_badges)}")

    # Log the final result
    log_common_badges(common_badges, collector.id)

    # Return the list of common badge IDs
    common_badges
  end


  defp log_common_badges([], collector_id) do
    Logger.info("Collector #{collector_id} has no common badges between its quests and direct associations")
  end
  defp log_common_badges(common_badges, collector_id) do
    Logger.info("Collector #{collector_id} shares badges between its quests and direct associations: #{inspect(common_badges)}")
  end

  # Adds common badges to the account
  defp add_common_badges_to_account(common_badge_ids, account) do
    Logger.debug("Adding common badges to account. Badge IDs: #{inspect(common_badge_ids)}")

    # Ensure common_badge_ids is a valid list of IDs
    if is_list(common_badge_ids) and not Enum.empty?(common_badge_ids) do
      Logger.debug("Fetching badges from database.")
      common_badges = Badges.list_badges_by_ids(common_badge_ids)

      Logger.debug("Fetched badges: #{inspect(common_badges)}")
      Enum.each(common_badges, fn badge ->
        Logger.debug("Attempting to add badge #{inspect(badge)} to account #{account.id}")
        case Accounts.add_badge_to_user(account.id, badge) do
          {:ok, msg, _updated_account} ->
            Logger.info("Badge #{badge.id} added to account #{account.id}: #{msg}")
          {:error, reason} ->
            Logger.error("Failed to add badge #{badge.id} to account #{account.id}: #{reason}")
        end
      end)
    else
      Logger.error("Invalid badge IDs: #{inspect(common_badge_ids)}")
    end
  end


end
