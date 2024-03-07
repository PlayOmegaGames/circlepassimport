defmodule QuestApiV21Web.SinglePageLive do
  use QuestApiV21Web, :live_view
  alias QuestApiV21Web.LiveComponents.Navbar
  alias QuestApiV21Web.LiveComponents.Badge
  alias QuestApiV21.Accounts

  def mount(_params, _session, socket) do
    account_email = socket.assigns.current_account.email
    account_struct = Accounts.get_account_by_email(account_email)

    badge_image =
    case Enum.at(account_struct.badges, 0) do
      nil -> nil
      badge -> badge.badge_image
    end

    badge_name =
      case Enum.at(account_struct.badges, 0) do
        nil -> nil
        badge -> badge.name
      end

    #IO.inspect(socket.assigns)
    IO.inspect(account_struct)

    badge_component = live_component(Badge, id: :badge, img: badge_image, name: badge_name)

    socket = assign(socket, page: "home", content: badge_component)
    {:ok, socket}
  end


  def render(assigns) do

    ~H"""
    <!-- page content -->
      <%= @page %>


      <div class="grid grid-cols-3 gap-4 justify-items-between my-4 mx-1">

        <div>
          <%= @content%>
        </div>

      </div>
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
