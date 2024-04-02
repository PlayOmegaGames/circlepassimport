defmodule QuestApiV21Web.QuestBarComponent do
  use Phoenix.LiveComponent

  def mount(_session, _params, socket) do
    account = socket.assigns.current_account

    selected_quest = QuestApiV21.Repo.preload(account, [:selected_quest])

    collected_badges_list = QuestApiV21.Repo.preload(selected_quest, [:badges])
    quest_with_badges = QuestApiV21.Repo.preload(selected_quest.selected_quest, [:badges])

    all_badges = quest_with_badges.badges
    quest = selected_quest.selected_quest
    collected_badges = collected_badges_list.badges
    # Calculate uncollected badges
    collected_badges_ids = Enum.map(collected_badges, & &1.id)
    uncollected_badges = Enum.reject(all_badges, fn badge -> badge.id in collected_badges_ids end)

    # Mark badges with their collection status
    marked_collected_badges = Enum.map(collected_badges, &Map.put(&1, :collected, true))
    marked_uncollected_badges = Enum.map(uncollected_badges, &Map.put(&1, :collected, false))

    # Combine badges into a single list, with collected badges first
    all_marked_badges = marked_collected_badges ++ marked_uncollected_badges

    socket =
      socket
      |> assign(:quest, quest)
      # Combined list with marked badges
      |> assign(:all_badges, all_marked_badges)
      # Initialize current index
      |> assign(:current_index, 0)
      |> assign(:socketid, socket.id)

    {:ok, socket |> update_current_badge()}
  end

  # Helper function to update the current badge based on the collected badges list and current index
  defp update_current_badge(socket) do
    all_badges = socket.assigns.all_badges
    current_index = socket.assigns.current_index

    current_badge = Enum.at(all_badges, current_index, %{})

    assign(socket, :badge, current_badge)
  end

  def render(assigns) do
    ~H"""
    <div>
      <div phx-hook="UpdateIndex" id="UpdateIndex" class="fixed bottom-1 border-2 border-gray-800">
        <div class="flex row">
          <div>
            <%= if assigns.badge.collected do %>
              <img class="w-12 h-auto rounded-full" src={assigns.badge.badge_image} />
            <% else %>
              <img class="grayscale w-12 h-auto rounded-full" src={assigns.badge.badge_image} />
            <% end %>
          </div>
          <div>
            <p class="text-light"><%= assigns.quest.name %></p>
            <p class="text-light"><%= assigns.badge.name %></p>
          </div>
        </div>
        <button phx-click="previous" class="border-2 m-8">Previous</button>
        <button phx-click="next" class="border-2 m-8">Next</button>
      </div>
    </div>
    """
  end

  def handle_event("initialize-index", %{"index" => index}, socket) do
    # Ensure the index is an integer
    new_index = String.to_integer(to_string(index))

    {:noreply,
     socket
     |> assign(:current_index, new_index)
     |> update_current_badge()}
  end

  def handle_event("next", _params, socket) do
    count = Enum.count(socket.assigns.all_badges)
    new_index = rem(socket.assigns.current_index + 1, count)

    # Notify the JS hook to log the index and update local storage
    socket =
      socket
      |> assign(:current_index, new_index)
      |> update_current_badge()
      |> push_event("update-local-storage", %{index: new_index})

    {:noreply, socket}
  end

  def handle_event("previous", _params, socket) do
    count = Enum.count(socket.assigns.all_badges)
    new_index = rem(socket.assigns.current_index - 1 + count, count)

    # Notify the JS hook to log the index and update local storage
    socket =
      socket
      |> assign(:current_index, new_index)
      |> update_current_badge()
      |> push_event("update-local-storage", %{index: new_index})

    {:noreply, socket}
  end
end
