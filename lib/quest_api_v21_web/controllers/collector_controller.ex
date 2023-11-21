defmodule QuestApiV21Web.CollectorController do
  use QuestApiV21Web, :controller

  alias QuestApiV21.Collectors
  alias QuestApiV21.Collectors.Collector
  alias QuestApiV21Web.JWTUtility

  action_fallback QuestApiV21Web.FallbackController

  def index(conn, _params) do
    collectors = Collectors.list_collectors()
    |> QuestApiV21.Repo.preload([:badges, :quests])

    render(conn, :index, collectors: collectors)
  end

  def create(conn, %{"collector" => collector_params}) do
    organization_id = JWTUtility.extract_primary_organization_id_from_jwt(conn)

    case Collectors.create_collector_with_organization(collector_params, organization_id) do
      {:ok, collector} ->
        collector = QuestApiV21.Repo.preload(collector, [:badges, :quests])
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/collector/#{collector}")
        |> render(:show, collector: collector)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{message: "Collector creation failed", errors: changeset})
    end
  end

  def show_collector(conn, %{"id" => id}) do
    collector = Collectors.get_collector!(id)
    |> QuestApiV21.Repo.preload([:quests, :badges])

    quest_name =
      case collector.quest_start do
        nil -> nil
        quest_id -> Collectors.get_quest_name(quest_id)
      end

    current_user = conn.assigns[:current_user]

    user_quests = if current_user do
      QuestApiV21.Repo.preload(current_user, [:quests, :badges]).quests
    else
      []
    end

    # Initialize a flag to indicate if a badge is added
    badge_added = false

    # Check if `quest_start` is not nil and not already associated with the user
    if collector.quest_start != nil and not Enum.any?(user_quests, fn quest -> quest.id == collector.quest_start end) do
      QuestApiV21.Accounts.add_quest_to_user(current_user.id, collector.quest_start)

      # Add a badge to the user's account and set the flag
      {:ok, _} = QuestApiV21.Accounts.add_badge_to_user(current_user.id, Enum.at(collector.badges, 0))
      badge_added = true
    end

    render(conn, "collector.html",
      collector: collector,
      quest_name: quest_name,
      current_user: current_user,
      user_quests: user_quests,
      badges: collector.badges,
      badge_added: badge_added  # Pass this flag to the view
    )
  end

  def show(conn, %{"id" => id}) do
    case Collectors.get_collector(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("error.json", message: "Collector not found")

      %Collector{} = collector ->
        render(conn, :show, collector: collector)
    end
  end

  def update(conn, %{"id" => id, "collector" => collector_params}) do
    collector = Collectors.get_collector!(id)

    with {:ok, %Collector{} = collector} <- Collectors.update_collector(collector, collector_params) do
      collector = QuestApiV21.Repo.preload(collector, [:badges, :quests])
      render(conn, :show, collector: collector)
    end
  end


  def delete(conn, %{"id" => id}) do
    collector = Collectors.get_collector!(id)

    with {:ok, %Collector{}} <- Collectors.delete_collector(collector) do
      send_resp(conn, :no_content, "")
    end
  end

end
