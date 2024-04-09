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
    collected_badges_ids =
      QuestApiV21.Quests.get_collected_badges_ids_for_quest(account.id, quest.id)

    # Mark all badges with their collection status in one pass.
    marked_badges =
      Enum.map(all_badges, fn badge ->
        collected = badge.id in collected_badges_ids
        Map.put(badge, :collected, collected)
      end)

    comp_percent =
      trunc(Enum.count(marked_badges, & &1.collected) / Enum.count(marked_badges) * 100)

    socket =
      socket
      |> assign(:show_badge_details, false)
      |> assign(:show_camera, false)
      |> assign(:my_target, self())
      |> assign(:quest, quest)
      # Updated logic here
      |> assign(:all_badges, marked_badges)
      |> assign(:current_index, 0)
      |> assign(:socketid, socket.id)
      |> assign(:comp_percent, comp_percent)
      |> assign(:qr_loading, false)
      |> assign(:show_qr_success, false)

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
      <.live_component
        module={QuestApiV21Web.LiveComponents.BadgeDetails}
        id="example-modal"
        show={@show_badge_details}
        on_confirm={:confirm_action}
        on_cancel={:cancel_action}
        confirm="Proceed"
        badge={@badge}
        quest={@quest}
        comp_percent={@comp_percent}
        cancel="Cancel"
      />

      <.live_component
        module={QuestApiV21Web.LiveComponents.Camera}
        id="camera_modal"
        show={@show_camera}
        on_confirm={:confirm_action}
        on_cancel={:cancel_action}
        confirm="Proceed"
        cancel="close-camera"
      />

      <.live_component
        module={QuestApiV21Web.LiveComponents.QrSuccess}
        id="qr-success"
        show={@show_qr_success}
      />

      <div
        phx-click="toggle_badge_details_modal"
        id="quest-bar-container"
        class="z-10 w-full bg-gradient-to-r from-gray-300 to-violet-100 border-t-2 border-contrast"
      >
        <div class="flex py-1">
          <div class="flex row transition-all ease-in-out quest-bar-content grow z-20">
            <span
              phx-click="next"
              class="hero-chevron-double-left text-gray-400/50 px-2 my-auto w-6 h-6"
            >
            </span>

            <div class="flex">
              <div class="mr-4 ml-1">
                <%= if assigns.badge.collected do %>
                  <img
                    class="object-cover w-12 h-12 ring-2 ring-highlight rounded-full"
                    src={assigns.badge.badge_image}
                  />
                <% else %>
                  <img
                    class="object-cover w-12 h-12 rounded-full ring-1 ring-slate-600 grayscale"
                    src={assigns.badge.badge_image}
                  />
                <% end %>
              </div>
              <div>
                <p class="truncate font-medium"><%= assigns.badge.name %></p>
                <p class="truncate text-xs font-light"><%= assigns.quest.name %></p>
              </div>
            </div>
            <div class="my-auto text-gray-400 z-10 mr-4">
              <span
                phx-click="next"
                class="hero-chevron-double-right text-gray-400/50 px-2 my-auto w-6 h-6"
              >
              </span>
            </div>
          </div>

          <div class="flex justify-between">
            <div class="my-auto mr-4 z-20">
              <button
                phx-click="camera"
                class="ring-1 p-1 ring-gray-400 z-30 shadow-sm shadow-highlight/[0.60] bg-gray-100 rounded-lg"
              >
                <span class="hero-qr-code w-8 h-8"></span>
              </button>
            </div>
          </div>
        </div>

        <div class="h-1 bg-gold-300" style={"width:#{@comp_percent}%"}></div>
      </div>
    </div>
    """
  end

  def handle_info(%{event: "selected_quest_updated", quest_id: quest_id}, socket) do
    Logger.info("Selected quest updated to #{quest_id}")

    # Assuming you have a way to fetch the complete quest object along with its badges
    # and the current account's collected badges for this quest.
    account_id = socket.assigns.current_account.id

    # Fetch the updated quest information based on the new quest_id
    quest =
      QuestApiV21.Quests.get_quest(quest_id)
      |> QuestApiV21.Repo.preload([:badges])

    # Calculate the completion percentage and other related information again
    collected_badges_ids =
      QuestApiV21.Quests.get_collected_badges_ids_for_quest(account_id, quest_id)

    marked_badges =
      Enum.map(quest.badges, fn badge ->
        collected = badge.id in collected_badges_ids
        Map.put(badge, :collected, collected)
      end)

    comp_percent =
      trunc(Enum.count(marked_badges, & &1.collected) / Enum.count(marked_badges) * 100)

    # Update the socket with the new quest information and reassign other necessary details
    socket =
      socket
      |> assign(:quest, quest)
      |> assign(:all_badges, marked_badges)
      |> assign(:comp_percent, comp_percent)
      |> assign(:animate_out, true)
      |> assign(:qr_loading, false)
      |> update_current_badge()

    # Schedule the in-animation to start shortly after the out-animation completes
    Process.send_after(self(), {:start_in_animation, quest_id}, 1_000)
    {:noreply, socket}
  rescue
    _ ->
      # Log or handle error
      {:noreply, socket}
  end

  def handle_info({:start_in_animation, quest_id}, socket) do
    # Assuming you want to perform some action when the animation starts, such as updating the socket assigns
    # or logging the event. Adjust this part according to your actual needs.
    Logger.info("Starting in-animation for quest #{quest_id}")

    # For example, if you want to reset `animate_out` to false to indicate the animation has completed,
    # and potentially show something else or update any related state, you can do so here.
    new_socket = assign(socket, animate_out: false)

    # Return the updated socket. No changes are necessary if you're only logging.
    {:noreply, new_socket}
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

  # badge details modal

  def handle_event("toggle_badge_details_modal", _params, socket) do
    new_visibility = not socket.assigns.show_badge_details
    {:noreply, assign(socket, :show_badge_details, new_visibility)}
  end

  def handle_event("camera", _params, socket) do
    new_visibility = not socket.assigns.show_camera
    {:noreply, assign(socket, :show_camera, new_visibility)}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, :show_badge_details, false)}
  end

  def handle_event("close-camera", _params, socket) do
    {:noreply, assign(socket, :show_camera, false)}
  end

  def handle_event("qr-code-scanned", %{"data" => qr_data}, socket) do
    # Parse the QR data as a URL
    uri = URI.parse(qr_data)
    IO.inspect(uri.host)

    # Define a list of allowed domains
    allowed_domains = ["questapp.io", "staging.questapp.io"]

    # Check if the parsed URL's host is in the list of allowed domains
    cond do
      uri.host in allowed_domains ->
        # Since the domain is valid, reconstruct the path for redirection
        full_path = uri.path
        Logger.info("Redirecting to: #{full_path}")
        socket = assign(socket, :show_qr_success, true)

        {:noreply, push_redirect(socket, to: full_path)}

      true ->
        IO.inspect(uri)
        # Log and handle the case where the domain does not match the allowed list
        Logger.error("Invalid domain in scanned QR code: #{uri.host}")
        {:noreply, socket}
    end
  end

end
