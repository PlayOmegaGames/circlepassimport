defmodule QuestApiV21Web.CollectorQuestStartNil do
  use QuestApiV21Web, :controller
  require Logger

  def handle_nil_quest_start(conn, collector) do
    current_account = conn.assigns[:current_user]
    compare_quests(collector, current_account)
    render(conn, "collector.html", collector: collector)
  end

  defp compare_quests(collector, account) do
    collector_quests = Enum.map(collector.quests, & &1.id)
    account_quests = Enum.map(account.quests, & &1.id)

    common_quests = for cq <- collector_quests, Enum.member?(account_quests, cq), do: cq

    if Enum.empty?(common_quests) do
      Logger.info("Collector #{collector.id} and account #{account.id} have no quests in common")
    else
      Logger.info("Collector #{collector.id} and account #{account.id} share quests: #{inspect(common_quests)}")
    end
  end
end
