defmodule QuestApiV21Web.Web.PageController do
  use QuestApiV21Web, :controller
  require Logger
  def home(conn, _params) do
    user_email = get_session(conn, :user_email)
    user_id = get_session(conn, :user_id)

    render(conn, "home.html", user_email: user_email, user_id: user_id)
  end

  def sign_in(conn, _params) do
    conn
      |> assign(:body_class, "bg-gradient-to-b from-purple-400 to-brand h-screen bg-no-repeat")
      |> render("sign_in.html")
  end

  def sign_up(conn, _params) do
    render(conn, "sign_up.html")
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html")
  end

  def new_page(conn, _params) do
    quests = QuestApiV21.Quests.list_public_quests()
    current_date = Date.utc_today()

   # Dividing quests into available and future
   {available_quests, future_quests} = Enum.split_with(quests, fn quest ->
    # Log the start_date for each quest
    Logger.debug("Quest #{quest.name} start date: #{inspect(quest.start_date)}")

      quest.start_date == nil or (quest.start_date && Date.compare(quest.start_date, current_date) != :gt)
    end)

    # Calculating badge count
    available_quests_with_badge_count = calculate_badge_count(available_quests)
    future_quests_with_badge_count = calculate_badge_count(future_quests)

    conn
    |> put_layout(html: :logged_in)
    |> assign(:body_class, "bg-light-blue")
    |> render("new_page.html", %{
      page_title: "New",
      camera: true,
      available_quests: available_quests_with_badge_count,
      future_quests: future_quests_with_badge_count
    })
  end

  def camera(conn, _params) do
    conn
    |> put_layout(html: :logged_in)
    |> render("camera.html", %{page_title: "Camera", camera: false})
  end

  defp calculate_badge_count(quests) do
    Enum.map(quests, fn quest ->
      badge_count = if Enum.empty?(quest.badges), do: "?", else: Enum.count(quest.badges)
      Map.put(quest, :badge_count, badge_count)
    end)
  end


  def profile(conn, _params) do
    account = conn.assigns[:current_user]
    #IO.inspect(account)
    conn
    |> put_layout(html: :logged_in)
    |> assign(:body_class, "bg-white")
    |> render("profile.html", %{page_title: "Profile", account: account, camera: true})
  end

  def auth_splash(conn, _params) do
    conn
    |> assign(:body_class, "bg-gradient-to-b from-purple-400 to-brand h-screen bg-no-repeat")
    |> render("auth_splash.html")
  end

  def redirect_to_badges(conn, _params) do
    conn
    |> redirect(to: "/badges")
  end
end
