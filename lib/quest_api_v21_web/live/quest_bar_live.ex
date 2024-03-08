defmodule QuestApiV21Web.QuestBarLive do
  use QuestApiV21Web, :live_view

  on_mount {QuestApiV21Web.AccountAuth, :mount_current_account}

  def mount(_session, _params, socket) do
    account = socket.assigns.current_account

    #IO.inspect(account)

    selected_quest = QuestApiV21.Repo.preload(account, [:selected_quest])

    #IO.inspect(selected_quest.selected_quest.badge_count)

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
    comp_percent = trunc(Enum.count(collected_badges) / Enum.count(all_marked_badges) * 100)


    socket =
      socket
      |> assign(:show_modal, false)
      |> assign(:show_camera, false)
      |> assign(:my_target, self())
      |> assign(:quest, quest)
      |> assign(:all_badges, all_marked_badges) # Combined list with marked badges
      |> assign(:current_index, 0) # Initialize current index
      |> assign(:socketid, socket.id)
      |> assign(:comp_percent, comp_percent)


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

    <%= live_component QuestApiV21Web.LiveComponents.BadgeDetails,
    id: "example-modal",
    show: @show_modal,
    on_confirm: :confirm_action,
    on_cancel: :cancel_action,
    confirm: "Proceed",
    badge: @badge,
    quest: @quest,
    comp_percent: @comp_percent,
    cancel: "Cancel" %>


    <%= live_component QuestApiV21Web.LiveComponents.Camera,
    id: "camera_modal",
    show: @show_camera,
    on_confirm: :confirm_action,
    on_cancel: :cancel_action,
    confirm: "Proceed",
    cancel: "close-camera" %>


    <div phx-click="toggle_badge_details_modal" phx-hook="UpdateIndex" id="UpdateIndex" class="fixed bottom-20 border-t-2 w-full border-gray-800">

    <div class="flex justify-between ">
      <div class="flex row">
        <div class="mr-4">
          <%= if assigns.badge.collected do %>
            <img class="w-12 h-auto rounded-full" src={assigns.badge.badge_image} />
          <% else %>
          <img class="grayscale w-12 h-auto rounded-full" src={assigns.badge.badge_image} />
          <% end %>

        </div>
        <div>

          <p class="text-light truncate" ><%= assigns.quest.name %> </p>
          <p class="text-light truncate" ><%= assigns.badge.name %> </p>
        </div>
      </div>
      <div>
        <button phx-click="previous" class="border-2 m-2">
          <span class="hero-chevron-double-left"/>
        </button>
        <button phx-click="next" class="border-2 m-2">
          <span class="hero-chevron-double-right" />
        </button>

        <button phx-click="camera" class="border-2 m-2 bg-brand text-white w-10 h-10 rounded-full">
          <span class="hero-qr-code w-6 h-6" />
        </button>
      </div>

        </div>
        <div class="h-1 bg-brand" style={"width:#{@comp_percent}%"} ></div>
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

  #badge details modal

  def handle_event("toggle_badge_details_modal", _params, socket) do
    new_visibility = not socket.assigns.show_modal
    {:noreply, assign(socket, :show_modal, new_visibility)}
  end

  def handle_event("camera", _params, socket) do
    new_visibility = not socket.assigns.show_camera
    {:noreply, assign(socket, :show_camera, new_visibility)}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, :show_modal, false)}
  end

  def handle_event("close-camera", _params, socket) do
    {:noreply, assign(socket, :show_camera, false)}
  end

  def handle_event("qr-code-scanned", %{"data" => qr_data}, socket) do
    uri = URI.parse(qr_data)
    IO.inspect(uri.host)
    # Check if the URI's host matches one of the allowed domains
    cond do
      uri.host in ["questapp.io", "4000-circlepassio-questapiv2-nqb4a6c031c.ws-us108.gitpod.io", "staging.questapp.io"] ->
        # If the domain is valid, redirect to the path in the QR code
        # Ensure the path is a valid route in your Phoenix app

        {:noreply, push_patch(socket, to: uri.path)}
      true ->
        # Handle the case where the domain does not match
        {:noreply, socket}
    end
  end
end
