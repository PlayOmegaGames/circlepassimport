defmodule QuestApiV21Web.Web.CollectorController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Collectors
  alias QuestApiV21.Collectors.Collector
  alias QuestApiV21Web.Web.CollectorQuestStartNil
  alias QuestApiV21Web.Web.CollectorQuestStartPresent

  require Logger

  # This action displays detailed information about a specific collector.
  # It is triggered when a GET request is made to "/badge/:id".

  def show_collector(conn, %{"id" => id}) do
    #IO.inspect(conn)

    case Collectors.get_collector(id) do
      nil ->
        Logger.error("Collector not found for ID: #{id}")
        conn
        |> put_status(:not_found)
        |> render("error.json", message: "Collector not found")

      %Collector{quest_start: nil} = collector ->
        # Logger.info("Collector #{collector.id}'s quest start field is empty")
        CollectorQuestStartNil.handle_nil_quest_start(conn, collector)

      %Collector{} = collector ->
        # Logger.info("Collector #{collector.id}'s quest start is present: #{collector.quest_start}")
        CollectorQuestStartPresent.handle_present_quest_start(conn, collector)
    end
  end
end
