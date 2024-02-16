defmodule QuestApiV21Web.Web.BadgeController do
  use QuestApiV21Web, :controller

  #  alias QuestApiV21.Badges
  alias QuestApiV21.Badges.Badge
  alias QuestApiV21.Accounts
  alias QuestApiV21.Repo

  def show_badge(conn, _params) do
    current_user = conn.assigns[:current_user]

    if current_user do
      # Preload badges and quests for the current user
      user_with_badges_and_quests = Repo.preload(current_user, [:badges, :quests])

      # Get all badges and group them by quest ID
      all_badges = Repo.all(Badge)
      badges_by_quest = Enum.group_by(all_badges, & &1.quest_id)
      user_badge_ids = Enum.map(user_with_badges_and_quests.badges, & &1.id)

      # Prepare badges data for rendering
      enhanced_badges_by_quest =
        Enum.map(badges_by_quest, fn {quest_id, badges} ->
          {quest_id, prepare_badge_data(badges, user_badge_ids)}
        end)
        |> Enum.into(%{})

      # Determine if there are any active quests using the context function
      has_active_quests = Accounts.has_active_quests?(current_user.id)
      IO.inspect(has_active_quests)
      # Render the page with all necessary assigns
      conn
      |> put_layout(html: :logged_in)
      |> assign(:body_class, "bg-light-neo")
      |> assign(:has_active_quests, has_active_quests)
      |> render("badge.html", %{
        badges_by_quest: enhanced_badges_by_quest,
        quests: user_with_badges_and_quests.quests,
        user_badge_ids: user_badge_ids,
        page_title: "Home",
        camera: true
      })
    end
  end

  def prepare_badge_data(badges, user_badge_ids) do
    Enum.map(badges, fn badge ->
      badge_data = Map.from_struct(badge)

      is_clickable =
        badge.id in user_badge_ids and not is_nil(badge.badge_details_image) and
          not is_nil(badge.badge_description)

      attributes =
        if is_clickable,
          do: [
            {:data_badge_details_image, badge.badge_details_image},
            {:data_badge_description, badge.badge_description}
          ],
          else: []

      Map.merge(badge_data, %{
        is_clickable: is_clickable,
        class: if(is_clickable, do: "badge-container clickable", else: "badge-container"),
        attributes: attributes
      })
    end)
  end
end
