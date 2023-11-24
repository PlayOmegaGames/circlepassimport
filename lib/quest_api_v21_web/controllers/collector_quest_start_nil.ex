defmodule QuestApiV21Web.CollectorQuestStartNil do
  use QuestApiV21Web, :controller
  alias QuestApiV21.{Accounts, Badges}
  require Logger

  @spec handle_nil_quest_start(
          atom() | %{:assigns => nil | maybe_improper_list() | map(), optional(any()) => any()},
          atom() | %{:id => any(), :quests => any(), optional(any()) => any()}
        ) :: :ok | Plug.Conn.t()
  def handle_nil_quest_start(conn, collector) do
    current_account = conn.assigns[:current_user]

    case compare_quests(collector, current_account) do
      [] ->
        Logger.info("No quests in common, rendering no_quest.html")
        render(conn, "no_quest.html", collector: collector, quests: collector.quests)

      common_quests_ids ->
        case compare_badges(collector) do
          [] ->
            Logger.info("No common badges, rendering a suitable template")
            # Render appropriate template or take action

          common_badges ->
            add_common_badges_to_account(common_badges, current_account)
            common_badge = common_badges |> List.first()
            badge = if common_badge, do: Badges.get_badge!(common_badge), else: nil
            render(conn, "collector.html", collector: collector, badge: badge)
        end
    end
  end

  defp compare_quests(collector, account) do
    collector_quests_ids = Enum.map(collector.quests, & &1.id)
    account_quests_ids = Enum.map(account.quests, & &1.id)

    common_quests_ids = collector_quests_ids |> Enum.filter(&Enum.member?(account_quests_ids, &1))
    log_common_quests(common_quests_ids, collector.id, account.id)
    common_quests_ids
  end

  defp log_common_quests([], collector_id, account_id) do
    Logger.info("Collector #{collector_id} and account #{account_id} have no quests in common")
  end

  defp log_common_quests(common_quests, collector_id, account_id) do
    Logger.info("Collector #{collector_id} and account #{account_id} share quests: #{inspect(common_quests)}")
  end

  defp compare_badges(collector) do
    collector_badges = Enum.map(collector.badges, & &1.id)
    Logger.debug("Collector badges: #{inspect(collector_badges)}")
    quest_badges = collector.quests |> Enum.flat_map(& &1.badges) |> Enum.map(& &1.id)
    Logger.debug("Quest badges: #{inspect(quest_badges)}")
    common_badges = Enum.filter(quest_badges, &Enum.member?(collector_badges, &1))
    Logger.debug("Common badges: #{inspect(common_badges)}")
    log_common_badges(common_badges, collector.id)
    common_badges
  end

  defp log_common_badges([], collector_id) do
    Logger.info("Collector #{collector_id} has no common badges between its quests and direct associations")
  end

  defp log_common_badges(common_badges, collector_id) do
    Logger.info("Collector #{collector_id} shares badges between its quests and direct associations: #{inspect(common_badges)}")
  end

  defp add_common_badges_to_account(common_badge_ids, account) do
    Logger.debug("Adding common badges to account. Badge IDs: #{inspect(common_badge_ids)}")
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
