defmodule QuestApiV21Web.BadgeController do
  use QuestApiV21Web, :controller
  alias QuestApiV21.Repo
  alias QuestApiV21.Badges
  alias QuestApiV21.Badges.Badge
  alias QuestApiV21Web.JWTUtility

  require Logger
  plug :put_layout, html: {QuestApiV21Web.Layouts, :logged_in}

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    organization_id = JWTUtility.get_organization_id_from_jwt(conn)

    case Badges.list_badges_by_organization_id(organization_id) do
      badges ->
        badges
        |> Repo.preload([:organization, :accounts])

        render(conn, :index, badges: badges)
    end
  end

  def create(conn, %{"badge" => badge_params}) do
    organization_id = JWTUtility.extract_organization_id_from_jwt(conn)

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
    badge =
      Badges.get_badge!(id)
      |> QuestApiV21.Repo.preload([:organization, :accounts])

    render(conn, :show, badge: badge)
  end

  def update(conn, %{"id" => id, "badge" => badge_params}) do
    organization_id = JWTUtility.extract_organization_id_from_jwt(conn)

    badge = Badges.get_badge!(id)

    with {:ok, %Badge{} = badge} <- Badges.update_badge(badge, badge_params, organization_id) do
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
