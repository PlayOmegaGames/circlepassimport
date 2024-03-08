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

      badge_components =
        account_struct.badges
        |> Enum.map(&badge_to_component/1)



    #IO.inspect(socket.assigns)
    IO.inspect(badge_components)

    badge_component = live_component(Badge, id: :badge, img: badge_image, name: badge_name)

    socket = assign(socket, page: "home", content: badge_components)
    {:ok, socket}
  end

  defp badge_to_component(badge) do
    %{
      id: badge.id,
      component: Badge,
      assigns: %{id: badge.id, img: badge.badge_image, name: badge.name}
    }
  end

  def render(assigns) do



    ~H"""
    <!-- page content -->
      <%= @page %>


      <div class="grid grid-cols-3 gap-4 justify-items-between my-4 mx-1">

        <div>
          <!-- content here -->
          <%= Enum.each(@content, fn %{component: component, assigns: assigns} ->
            IO.puts("Processing component with ID #{assigns.id}")
            # Do something with the component, e.g., render it
            # You can use live_render/3 or any other function related to the component here


          end) %>
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
