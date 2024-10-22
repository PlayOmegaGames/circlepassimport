defmodule QuestApiV21Web.QuestBarLive do
  use QuestApiV21Web, :live_view
  require Logger
  alias QuestApiV21.Repo
  alias QuestApiV21.Badges.LoyaltyBadgeData

  on_mount {QuestApiV21Web.AccountAuth, :mount_current_account}

  def mount(_session, _params, socket) do
    account = socket.assigns.current_account
    Phoenix.PubSub.subscribe(QuestApiV21.PubSub, "accounts:#{account.id}")

    selected_quest = Repo.preload(account, selected_quest: [badges: :collector])
    quest = selected_quest.selected_quest
    all_badges = quest.badges

    collected_badges_ids =
      QuestApiV21.Quests.get_collected_badges_ids_for_quest(account.id, quest.id)

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
      |> assign(:all_badges, marked_badges)
      |> assign(:current_index, 0)
      |> assign(:socketid, socket.id)
      |> assign(:comp_percent, comp_percent)
      |> assign(:qr_loading, false)
      |> assign(:show_qr_success, false)
      |> assign(:account_id, account.id)
      |> assign(:coordinates, nil)
      |> assign(:camera_error, nil)

    {:ok, update_current_badge(socket)}
  end

  defp update_current_badge(socket) do
    all_badges = socket.assigns.all_badges
    current_index = socket.assigns.current_index

    current_badge = Enum.at(all_badges, current_index, %{:collected => false})
    current_badge = Repo.preload(current_badge, [:quest, :collector])

    collector_coordinates = get_collector_coordinates(current_badge)

    socket =
      if current_badge.loyalty_badge do
        loyalty_data =
          LoyaltyBadgeData.fetch_loyalty_data(socket.assigns.account_id, current_badge)

        socket
        |> assign(:loyalty_data, loyalty_data)
        |> assign(:badge, current_badge)
        |> assign(:coordinates, collector_coordinates)
      else
        socket
        |> assign(:loyalty_data, %{
          total_transactions: nil,
          total_points: nil,
          next_reward: nil,
          next_scan_date: nil
        })
        |> assign(:badge, current_badge)
        |> assign(:coordinates, collector_coordinates)
      end

    socket
  end

  defp get_collector_coordinates(badge) do
    case badge.collector do
      nil ->
        %{latitude: nil, longitude: nil}

      collector ->
        coordinates = collector.coordinates

        if is_binary(coordinates) and String.contains?(coordinates, ",") do
          [latitude, longitude] = String.split(coordinates, ",")

          %{
            latitude: String.to_float(String.trim(latitude)),
            longitude: String.to_float(String.trim(longitude))
          }
        else
          %{latitude: nil, longitude: nil}
        end
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={QuestApiV21Web.LiveComponents.BadgeDetails}
        id="badge-details"
        show={@show_badge_details}
        on_confirm={:confirm_action}
        on_cancel={:cancel_action}
        confirm="Proceed"
        badge={@badge}
        quest={@quest}
        account_id={@account_id}
        total_transactions={@loyalty_data.total_transactions}
        total_points={@loyalty_data.total_points}
        next_reward={@loyalty_data.next_reward}
        next_scan_date={@loyalty_data.next_scan_date}
        cancel="Cancel"
        comp_percent={@comp_percent}
        coordinates={@coordinates}
      />

      <.live_component
        module={QuestApiV21Web.LiveComponents.Camera}
        id="camera_modal"
        show={@show_camera}
        on_confirm={:confirm_action}
        on_cancel={:cancel_action}
        camera_error={@camera_error}
        confirm="Proceed"
        cancel="close-camera"
      />

      <.live_component
        module={QuestApiV21Web.LiveComponents.QrSuccess}
        id="qr-success"
        show={@show_qr_success}
      />
      <div class="px-0.5 bg-white rounded-t-xl">
        <div
          phx-click="toggle_badge_details_modal"
          id="quest-bar-container"
          class="relative rounded-xl z-10 w-full bg-gradient-to-r from-gray-100 to-gray-100 ring-transparent border border-gray-400"
        >
          <div class="flex py-1">
            <div class="flex justify-between row transition-all ease-in-out quest-bar-content grow z-20">
              <span
                phx-click="previous"
                class="hero-chevron-double-left text-gray-400/50 ml-2 my-auto w-6 h-6"
              >
              </span>

              <div class="flex">
                <div class="mr-4 ml-1 mt-2">
                  <%= if assigns.badge.collected do %>
                    <span class="inline-block">
                      <img
                        class="object-cover w-12 h-12 ring-1 ring-gold-100 rounded-full"
                        src={assigns.badge.badge_image}
                      />
                    </span>
                  <% else %>
                    <span class="relative inline-block my-auto">
                      <span class="bg-brand/90 ring-gray-400 ring-1 absolute top-0 -right-1 rounded-full h-3 w-3 z-30 ">
                      </span>
                      <span class="bg-brand/90 absolute top-0 -right-1 rounded-full h-3 w-3 z-30 animate animate-ping">
                      </span>
                      <img
                        class="object-cover w-12 h-12 rounded-full ring-1 ring-slate-600 grayscale"
                        src={assigns.badge.badge_image}
                      />
                    </span>
                  <% end %>
                </div>
                <div class="my-auto">
                  <p class="truncate text-sm font-medium"><%= assigns.badge.name %></p>
                  <p class="truncate text-xs font-light"><%= assigns.quest.name %></p>
                </div>
              </div>
              <div class="my-auto text-gray-400 z-10 mr-4">
                <span
                  phx-click="next"
                  class="hero-chevron-double-right text-gray-400/50 ml-3 my-auto w-6 h-6"
                >
                </span>
              </div>
            </div>
            <!-- Camera -->
            <div class="flex justify-between border-l-2 border-gray-200">
              <div class="my-auto  px-5 z-20">
                <button
                  phx-click="camera"
                  class="ring-1 p-1 ring-gray-400 z-30 shadow-md shadow-brand/60 bg-gray-100 rounded-lg"
                >
                  <img class="w-8 h-8 opacity-70" src="/images/qr-code.png" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_info(%{event: "selected_quest_updated", quest_id: quest_id}, socket) do
    Logger.info("Selected quest updated to #{quest_id}")

    account_id = socket.assigns.current_account.id

    quest =
      QuestApiV21.Quests.get_quest(quest_id)
      |> QuestApiV21.Repo.preload([:badges])

    collected_badges_ids =
      QuestApiV21.Quests.get_collected_badges_ids_for_quest(account_id, quest_id)

    marked_badges =
      Enum.map(quest.badges, fn badge ->
        collected = badge.id in collected_badges_ids
        Map.put(badge, :collected, collected)
      end)

    comp_percent =
      trunc(Enum.count(marked_badges, & &1.collected) / Enum.count(marked_badges) * 100)

    socket =
      socket
      |> assign(:quest, quest)
      |> assign(:all_badges, marked_badges)
      |> assign(:comp_percent, comp_percent)
      |> assign(:animate_out, true)
      |> assign(:qr_loading, false)
      |> update_current_badge()

    Process.send_after(self(), {:start_in_animation, quest_id}, 1_000)
    {:noreply, socket}
  end

  def handle_info({:start_in_animation, _quest_id}, socket) do
    # Logger.info("Starting in-animation for quest #{quest_id}")
    new_socket = assign(socket, animate_out: false)
    {:noreply, new_socket}
  end

  def handle_event("initialize-index", %{"index" => index}, socket) do
    new_index = String.to_integer(to_string(index))
    {:noreply, socket |> assign(:current_index, new_index) |> update_current_badge()}
  end

  def handle_event("next", _params, socket) do
    count = Enum.count(socket.assigns.all_badges)
    new_index = rem(socket.assigns.current_index + 1, count)

    {:noreply,
     socket
     |> assign(:current_index, new_index)
     |> update_current_badge()
     |> push_event("update-local-storage", %{index: new_index})}
  end

  def handle_event("previous", _params, socket) do
    count = Enum.count(socket.assigns.all_badges)
    new_index = rem(socket.assigns.current_index - 1 + count, count)

    {:noreply,
     socket
     |> assign(:current_index, new_index)
     |> update_current_badge()
     |> push_event("update-local-storage", %{index: new_index})}
  end

  def handle_event("toggle_badge_details_modal", _params, socket) do
    new_visibility = not socket.assigns.show_badge_details
    {:noreply, assign(socket, :show_badge_details, new_visibility)}
  end

  def handle_event("camera", _params, socket) do
    new_visibility = not socket.assigns.show_camera
    {:noreply, assign(socket, :show_camera, new_visibility)}
  end

  def handle_event("camera-error", %{"message" => msg}, socket) do
    {:noreply, assign(socket, :camera_error, msg)}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, :show_badge_details, false)}
  end

  def handle_event("close-camera", _params, socket) do
    {:noreply, assign(socket, :show_camera, false)}
  end

  def handle_event("qr-code-scanned", %{"data" => qr_data}, socket) do
    # Ensure the QR data has a scheme, defaulting to https if not provided
    qr_data =
      if String.starts_with?(qr_data, ["http://", "https://"]) do
        qr_data
      else
        "https://" <> qr_data
      end

    uri = URI.parse(qr_data)
    allowed_domains = ["questapp.io", "staging.questapp.io"]

    cond do
      uri.host in allowed_domains ->
        # Construct the relative path only
        relative_path = uri.path <> ((uri.query != nil && "?#{uri.query}") || "")
        Logger.info("Redirecting to: #{relative_path}")
        socket = assign(socket, :show_qr_success, true)
        {:noreply, push_redirect(socket, to: relative_path)}

      true ->
        Logger.error("Invalid domain in scanned QR code: #{uri.host}")
        {:noreply, socket}
    end
  end
end
