defmodule QuestApiV21Web.BadgeController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Badges
  alias QuestApiV21.Badges.Badge

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    badge = Badges.list_badge()
    |> QuestApiV21.Repo.preload([:organization, :accounts])

    render(conn, :index, badge: badge)
  end

  def create(conn, %{"badge" => badge_params}) do
    with {:ok, %Badge{} = badge} <- Badges.create_badge(badge_params) do
      badge = QuestApiV21.Repo.preload(badge, [:accounts])
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/badge/#{badge}")
      |> render(:show, badge: badge)
    end
  end

  def show(conn, %{"id" => id}) do
    badge = Badges.get_badge!(id)
    |> QuestApiV21.Repo.preload([:organization, :accounts])


    render(conn, :show, badge: badge)
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
