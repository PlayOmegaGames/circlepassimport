defmodule QuestApiV21Web.QuestBarLive do
  use QuestApiV21Web, :live_view
  require Logger
  on_mount {QuestApiV21Web.AccountAuth, :mount_current_account}

  def mount(_session, _params, socket) do
    account = socket.assigns.current_account

    Phoenix.PubSub.subscribe(QuestApiV21.PubSub, "accounts:#{account.id}")

    selected_quest = QuestApiV21.Repo.preload(account, selected_quest: [:badges])
    quest = selected_quest.selected_quest
    all_badges = quest.badges

    # Assuming there's a way to directly get IDs of all badges collected by the user for this quest.
    # This step may require adjusting your data model or query approach.
    collected_badges_ids = QuestApiV21.Quests.get_collected_badges_ids_for_quest(account.id, quest.id)

    # Mark all badges with their collection status in one pass.
    marked_badges = Enum.map(all_badges, fn badge ->
      collected = badge.id in collected_badges_ids
      Map.put(badge, :collected, collected)
    end)

    comp_percent = trunc(Enum.count(marked_badges, &(&1.collected)) / Enum.count(marked_badges) * 100)

    socket =
      socket
      |> assign(:show_modal, false)
      |> assign(:show_camera, false)
      |> assign(:my_target, self())
      |> assign(:quest, quest)
      |> assign(:all_badges, marked_badges) # Updated logic here
      |> assign(:current_index, 0)
      |> assign(:socketid, socket.id)
      |> assign(:comp_percent, comp_percent)

    {:ok, update_current_badge(socket)}
  end


  # Helper function to update the current badge based on the collected badges list and current index
  defp update_current_badge(socket) do
    all_badges = socket.assigns.all_badges
    current_index = socket.assigns.current_index

    # Ensure the default map includes :collected to prevent KeyError
    current_badge = Enum.at(all_badges, current_index, %{:collected => false})

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


    <div phx-click="toggle_badge_details_modal" phx-hook="UpdateIndex" id="UpdateIndex" class="fixed bottom-14 z-10 w-full bg-white border-t border-gray-800 -2">

    <div class="flex justify-between">
      <div class="flex row">
        <div class="mr-4">
          <%= if assigns.badge.collected do %>
            <img class="object-cover w-12 h-12 rounded-full" src={assigns.badge.badge_image} />
          <% else %>
          <img class="object-cover w-12 h-12 rounded-full grayscale" src={assigns.badge.badge_image} />
          <% end %>

        </div>
        <div>

          <p class="truncate text-light" ><%= assigns.quest.name %> </p>
          <p class="truncate text-light" ><%= assigns.badge.name %> </p>
        </div>
      </div>
      <div>
        <button phx-click="previous" class="m-2 border-2">
          <span class="hero-chevron-double-left"/>
        </button>
        <button phx-click="next" class="m-2 border-2">
          <span class="hero-chevron-double-right" />
        </button>

        <button phx-click="camera" class="m-2 w-10 h-10 text-white rounded-full border-2 bg-brand">
          <span class="w-6 h-6 hero-qr-code" />
        </button>
      </div>

        </div>
        <div class="h-1 bg-brand" style={"width:#{@comp_percent}%"} ></div>
      </div>

    </div>

    """
  end

  def handle_info(message, socket) do
    # Log the message received from PubSub
    Logger.info("Received PubSub Message: #{inspect(message)}")

    # Here, you might want to update the socket based on the message content
    # For demonstration, we're just returning the unchanged socket
    {:noreply, socket}
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
    # Split the path to extract the domain and the actual path
    [domain | rest_of_path] = String.split(qr_data, "/", parts: 2)
    actual_path = Enum.join(rest_of_path, "/") # Rejoin the rest of the path

    # Check if the extracted domain is in the list of allowed domains
    cond do
      domain in ["questapp.io", "4000-circlepassio-questapiv2-nqb4a6c031c.ws-us108.gitpod.io", "staging.questapp.io"] ->
        # Since the domain is valid, construct the full path for redirection
        full_path = "/" <> actual_path
        Logger.info("Redirecting to: #{full_path}")
        {:noreply, push_redirect(socket, to: full_path)}
      true ->
        # Log and handle the case where the domain does not match the allowed list
        Logger.error("Invalid domain in scanned QR code: #{domain}")
        {:noreply, socket}
    end
  end



end
