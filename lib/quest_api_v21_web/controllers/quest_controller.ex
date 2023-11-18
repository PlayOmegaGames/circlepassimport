defmodule QuestApiV21Web.QuestController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Quests
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21Web.JWTUtility

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    #passes org id onto context file for filtering
    organization_ids = JWTUtility.get_organization_ids_from_jwt(conn)
    quests = Quests.list_quests_by_organization_ids(organization_ids)
    render(conn, :index, quests: quests)
  end


  def create(conn, %{"quest" => quest_params}) do
    organization_id = JWTUtility.extract_primary_organization_id_from_jwt(conn)

    case Quests.create_quest_with_organization(quest_params, organization_id) do
      {:ok, quest} ->
        quest = QuestApiV21.Repo.preload(quest, [:organization, :badges, :collectors])
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/quests/#{quest}")
        |> render("show.json", quest: quest)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", message: "Quest creation failed", errors: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    quest = Quests.get_quest!(id)
    |> QuestApiV21.Repo.preload([:organization, :badges, :collectors])


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
