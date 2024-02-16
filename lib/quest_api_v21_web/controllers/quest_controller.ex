defmodule QuestApiV21Web.QuestController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Quests
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21Web.JWTUtility
  alias QuestApiV21.Repo

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    # passes org id onto context file for filtering
    organization_ids = JWTUtility.get_organization_ids_from_jwt(conn)

    quests =
      Quests.list_quests_by_organization_ids(organization_ids)
      # Preload accounts here
      |> Repo.preload([:organization, :badges, :collectors, :accounts])

    render(conn, :index, quests: quests)
  end

  def create(conn, %{"quest" => quest_params}) do
    organization_id = JWTUtility.extract_primary_organization_id_from_jwt(conn)
    # IO.inspect(organization_id, label: "Extracted Organization ID")

    case Quests.create_quest_with_organization(quest_params, organization_id) do
      {:ok, quest} ->
        quest = QuestApiV21.Repo.preload(quest, [:organization, :badges, :collectors, :accounts])

        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/quests/#{quest}")
        |> render("show.json", quest: quest)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{message: "Quest creation failed", errors: changeset})
    end
  end

  def show(conn, %{"id" => id}) do
    organization_ids = JWTUtility.get_organization_ids_from_jwt(conn)

    case Quests.get_quest(id, organization_ids) do
      nil ->
        send_resp(conn, :not_found, "")

      quest ->
        quest = QuestApiV21.Repo.preload(quest, [:organization, :badges, :collectors, :accounts])
        render(conn, :show, quest: quest)
    end
  end

  def update(conn, %{"id" => id, "quest" => quest_params}) do
    organization_ids = JWTUtility.get_organization_ids_from_jwt(conn)

    case Quests.get_quest(id, organization_ids) do
      nil ->
        send_resp(conn, :not_found, "")

      quest ->
        case Quests.update_quest(quest, quest_params, organization_ids) do
          {:ok, updated_quest} ->
            updated_quest =
              QuestApiV21.Repo.preload(updated_quest, [
                :organization,
                :badges,
                :collectors,
                :accounts
              ])

            render(conn, :show, quest: updated_quest)

          {:error, :unauthorized} ->
            send_resp(conn, :forbidden, "")

          {:error, _changeset} ->
            send_resp(conn, :unprocessable_entity, "")
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    organization_ids = JWTUtility.get_organization_ids_from_jwt(conn)

    case Quests.get_quest(id, organization_ids) do
      nil ->
        send_resp(conn, :not_found, "")

      quest ->
        case Quests.delete_quest(quest, organization_ids) do
          {:ok, %Quest{}} ->
            send_resp(conn, :no_content, "")

          {:error, :unauthorized} ->
            send_resp(conn, :forbidden, "")
        end
    end
  end
end
