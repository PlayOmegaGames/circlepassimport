defmodule QuestApiV21Web.Web.CollectorQuestStartNil do
  use QuestApiV21Web, :controller
  alias QuestApiV21.Badges
  alias QuestApiV21.Quests
  alias QuestApiV21.Collectors.Collector
  require Logger

  def handle_nil_quest_start(conn, %Collector{id: collector_id} = collector) do
    current_account = conn.assigns[:current_account]
    account_id = current_account.id

    # Use Quests context to compare quests
    with {:ok, common_quests_ids} <-
           Quests.compare_collector_account_quests(collector_id, account_id) do
      if Enum.empty?(common_quests_ids) do
        Logger.debug("No quests in common, rendering no_quest.html")

        conn
        |> put_layout(html: :logged_in)
        |> render("no_quest.html", %{
          page_title: "No Quest",
          camera: true,
          collector: collector,
          quests: collector.quests
        })
      else
        # Use Badges context to compare badges
        with {:ok, common_badges} <- Badges.compare_collector_badges_to_quest_badges(collector_id) do
          if Enum.empty?(common_badges) do
            Logger.info("No common badges, rendering a suitable template")
            # Render appropriate template or take action
          else
            # Update the following call to match your context function for adding badges to an account
            QuestApiV21.Accounts.add_badges_to_account(account_id, common_badges)
            |> handle_add_badges_result(conn, collector, common_badges)
          end
        else
          {:error, :collector_not_found} ->
            Logger.error("Collector not found.")
        end
      end
    else
      {:error, :entity_not_found} ->
        Logger.error("Collector not found.")
    end
  end

  defp handle_add_badges_result({:ok, _new_badges}, conn, collector, common_badges) do
    common_badge = common_badges |> List.first()
    badge = if common_badge, do: Badges.get_badge!(common_badge), else: nil
    render(conn, "collector.html", collector: collector, badge: badge)
  end
end
