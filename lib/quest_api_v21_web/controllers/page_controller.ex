defmodule QuestApiV21Web.PageController do
  use QuestApiV21Web, :controller

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
    #IO.inspect(quests)

    conn
    |> put_layout(html: :logged_in)
    |> assign(:body_class, "bg-light-blue")
    |> render("new_page.html", %{page_title: "New", quests: quests})
  end

  def profile(conn, _params) do
    account = conn.assigns[:current_user]
    #IO.inspect(account)
    conn
    |> put_layout(html: :logged_in)
    |> assign(:body_class, "bg-white")
    |> render("profile.html", %{page_title: "Profile", account: account})
  end

  def auth_splash(conn, _params) do
    conn
    |> assign(:body_class, "bg-gradient-to-b from-purple-400 to-brand h-screen bg-no-repeat")
    |> render("auth_splash.html")
  end
end
