defmodule QuestApiV21Web.QuestBarLive do
  use QuestApiV21Web, :live_view
  alias QuestApiV21Web.LiveComponents.CompTest

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
      |> assign(:all_badges, all_marked_badges) # Combined list with marked badges
      |> assign(:current_index, 0) # Initialize current index
      |> assign(:socketid, socket.id)
      |> assign(show_comp_test: false)

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
    <div class="fixed bottom-1 border-2 border-gray-800">
      <div class="flex row">
      <div>
        <%= if assigns.badge.collected do %>
          <img class="w-12 h-auto rounded-full" src={assigns.badge.badge_image} />
        <% else %>
        <img class="grayscale w-12 h-auto rounded-full" src={assigns.badge.badge_image} />
        <% end %>

      </div>
      <div>



        <p class="text-light" ><%= assigns.quest.name %> </p>
        <p class="text-light" ><%= assigns.badge.name %> </p>
      </div>

    </div>
      <button phx-click="previous" class="border-2 m-8">Previous</button>
      <button phx-click="next" class="border-2 m-8">Next</button>
    </div>

    <%= if @show_comp_test do %>
      <div class="fixed top-0 right-0 m-4">
        <%= live_component CompTest, id: :comp_test, name: "Emperor" %> <!-- Render CompTest with props -->
      </div>
    <% end %>
    """
  end

  def handle_event("next", _params, socket) do
    count = Enum.count(socket.assigns.all_badges)
    new_index = rem(socket.assigns.current_index + 1, count)

    {:noreply,
      socket
      |> assign(:current_index, new_index)
      |> update_current_badge()
    }
  end

  def handle_event("previous", _params, socket) do
      count = Enum.count(socket.assigns.all_badges)
      new_index = rem(socket.assigns.current_index - 1 + count, count)

      {:noreply,
        socket
        |> assign(:current_index, new_index)
        |> update_current_badge()
      }
  end

end
