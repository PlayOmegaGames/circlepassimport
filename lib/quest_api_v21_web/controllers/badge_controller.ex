defmodule QuestApiV21Web.BadgeController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Badges
  alias QuestApiV21.Badges.Badge
  alias QuestApiV21Web.JWTUtility
  alias QuestApiV21.Repo
  require Logger


  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    badge = Badges.list_badge()
    |> QuestApiV21.Repo.preload([:organization, :accounts])

    render(conn, :index, badge: badge)
  end

  def create(conn, %{"badge" => badge_params}) do
    organization_id = JWTUtility.extract_primary_organization_id_from_jwt(conn)

    case Badges.create_badge_with_organization(badge_params, organization_id) do
      {:ok, badge} ->
        badge = QuestApiV21.Repo.preload(badge, [:accounts])
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/badge/#{badge}")
        |> render(:show, badge: badge)

        {:error, changeset} ->
          Logger.error("Changeset error: #{inspect(changeset.errors)}")
          conn
          |> put_status(:unprocessable_entity)
          |> render("error.json", %{message: "Badge creation failed", errors: changeset})
      end
  end

  def show(conn, %{"id" => id}) do
    badge = Badges.get_badge!(id)
    |> QuestApiV21.Repo.preload([:organization, :accounts])


    render(conn, :show, badge: badge)
  end


  def show_badge(conn, _params) do
    current_user = conn.assigns[:current_user]

    if current_user do
      user_with_badges_and_quests = Repo.preload(current_user, [:badges, :quests])

      if Enum.empty?(user_with_badges_and_quests.badges) do
        render(conn, "no_badge.html")
      else
        all_badges = Repo.all(Badge)
        badges_by_quest = Enum.group_by(all_badges, &(&1.quest_id))
        user_badge_ids = Enum.map(user_with_badges_and_quests.badges, &(&1.id))

        enhanced_badges_by_quest = Enum.map(badges_by_quest, fn {quest_id, badges} ->
          {quest_id, prepare_badge_data(badges, user_badge_ids)}
        end)
        |> Enum.into(%{})

        render(conn, "badge.html",
          badges_by_quest: enhanced_badges_by_quest,  # Note the use of enhanced_badges_by_quest here
          quests: user_with_badges_and_quests.quests,
          user_badge_ids: user_badge_ids
        )
      end
    end
  end


  def prepare_badge_data(badges, user_badge_ids) do
    Enum.map(badges, fn badge ->
      badge_data = Map.from_struct(badge)
      is_clickable = badge.id in user_badge_ids and not is_nil(badge.redirect_url) and not is_nil(badge.badge_description)

      attributes = if is_clickable, do: [
        {:data_redirect_url, badge.redirect_url},
        {:data_badge_description, badge.badge_description}
      ], else: []

      Map.merge(badge_data, %{
        is_clickable: is_clickable,
        class: if(is_clickable, do: "badge-container clickable", else: "badge-container"),
        attributes: attributes
      })
    end)
  end




  def update(conn, %{"id" => id, "badge" => badge_params}) do
    badge = Badges.get_badge!(id)

    with {:ok, %Badge{} = badge} <- Badges.update_badge(badge, badge_params) do
      render(conn, :show, badge: badge)
    end
  end

  def delete(conn, %{"id" => id}) do
    badge = Badges.get_badge!(id)

    with {:ok, %Badge{}} <- Badges.delete_badge(badge) do
      send_resp(conn, :no_content, "")
    end
  end
end
