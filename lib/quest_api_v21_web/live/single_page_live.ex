defmodule QuestApiV21Web.SinglePageLive do
  use QuestApiV21Web, :live_view
  alias QuestApiV21Web.LiveComponents.Navbar
  alias QuestApiV21Web.LiveComponents.Badge
  alias QuestApiV21.Accounts

  def mount(_params, _session, socket) do
    account_email = socket.assigns.current_account.email
    account_struct = Accounts.get_account_by_email(account_email)

    #IO.inspect(socket.assigns)
    IO.inspect(account_struct.badges)

    socket = assign(socket, page: "home")
    {:ok, socket}
  end


  def render(assigns) do
    ~H"""
    <!-- page content -->
      <%= @page %>



      <%= live_component Badge, id: :badge %>
      <!-- Navbar Component -->
      <%= live_component Navbar, id: :navbar %>


    """
  end

  def handle_event("home", _, socket) do
    socket = assign(socket, page: "home")
    {:noreply, socket}
  end
  def handle_event("available quests", _, socket) do
    socket = assign(socket, page: "new")
    {:noreply, socket}
  end
  def handle_event("profile", _, socket) do
    socket = assign(socket, page: "profile")
    {:noreply, socket}
  end
end
