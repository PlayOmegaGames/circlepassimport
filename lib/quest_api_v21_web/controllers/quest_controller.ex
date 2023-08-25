defmodule QuestApiV21Web.QuestController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Quests
  alias QuestApiV21.Quests.Quest

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    quests = Quests.list_quests()
    |> QuestApiV21.Repo.preload([:business, :collection_points, :collectors])


    render(conn, :index, quests: quests)
  end

  def create(conn, %{"quest" => quest_params}) do
    with {:ok, %Quest{} = quest} <- Quests.create_quest(quest_params) do
      quest = QuestApiV21.Repo.preload(quest, [:business, :collection_points, :collectors])
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/quests/#{quest}")
      |> render(:show, quest: quest)
    end
  end

  def show(conn, %{"id" => id}) do
    quest = Quests.get_quest!(id)
    |> QuestApiV21.Repo.preload([:business, :collection_points, :collectors])


    render(conn, :show, quest: quest)
  end

  def update(conn, %{"id" => id, "quest" => quest_params}) do
    quest = Quests.get_quest!(id)

    with {:ok, %Quest{} = quest} <- Quests.update_quest(quest, quest_params) do
      render(conn, :show, quest: quest)
    end
  end

  def delete(conn, %{"id" => id}) do
    quest = Quests.get_quest!(id)

    with {:ok, %Quest{}} <- Quests.delete_quest(quest) do
      send_resp(conn, :no_content, "")
    end
  end
end
