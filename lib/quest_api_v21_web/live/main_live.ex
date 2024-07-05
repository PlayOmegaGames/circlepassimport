defmodule QuestApiV21Web.MainLive do
  use Phoenix.LiveView
  require Logger
  import Phoenix.HTML
  alias QuestApiV21.{Badges, Quests, Rewards}
  alias QuestApiV21Web.CoreComponents
  alias QuestApiV21.Repo

  def mount(_params, _session, socket) do
    # IO.inspect(socket.assigns.live_action, label: "mount live_action")

    account_id = socket.assigns.current_account.id
    # Generate QR Code
    qr_code_svg = generate_qr_code("https://questapp.io/gunter/#{account_id}")

    {:ok, badges} = Badges.get_badges_for_account(account_id)
    {:ok, quests} = Quests.get_quests_for_account(account_id)
    {:ok, rewards} = Rewards.get_rewards_for_account(account_id)
    account = socket.assigns.current_account
    quests_list = Quests.list_public_quests()

    current_date = Date.utc_today()

    {available_quests, future_quests} =
      Enum.split_with(quests_list, fn quest ->
        quest.start_date == nil or
          (quest.start_date && Date.compare(quest.start_date, current_date) != :gt)
      end)

    quests_with_completion = calculate_completion_percentage(quests, account_id)

    socket = assign(socket, quests: quests_with_completion)

    available_quests_with_badge_count = calculate_badge_count(available_quests)
    future_quests_with_badge_count = calculate_badge_count(future_quests)

    socket =
      socket
      |> assign(
        badges: badges,
        quests: quests,
        rewards: rewards,
        account: account,
        current_view: "home",
        tab: "badges",
        available_quests: available_quests_with_badge_count,
        future_quests: future_quests_with_badge_count,
        badge_detail: nil,
        quest_details: nil,
        quests_with_completion: quests_with_completion,
        show_single_badge_details: false,
        show_quest_details: false,
        show_reward_details: false,
        qr_code_svg: qr_code_svg
      )

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    # Default to "badges" tab if none specified
    tab = params["tab"] || "badges"

    background_color =
      case socket.assigns.live_action do
        _ -> "false"
      end

    socket =
      socket
      |> assign(tab: tab)
      |> assign(:background_color, background_color)

    {:noreply, socket}
  end

  defp calculate_completion_percentage(quests, account_id) do
    Enum.map(quests, fn quest ->
      total_badges = length(quest.badges)

      case QuestApiV21.Quests.get_earned_badges_for_quest_and_account(account_id, quest.id) do
        {:ok, earned_badges} ->
          completion_percentage =
            if total_badges > 0,
              do: round(earned_badges / total_badges * 100),
              else: 0

          # Return the quest map with the completion percentage added
          Map.put(quest, :completion_percentage, completion_percentage)
      end
    end)
  end

  def handle_event("navigate", _params, socket) do
    {:noreply, push_redirect(socket, to: "/accounts/settings")}
  end

  defp calculate_badge_count(quests) do
    Enum.map(quests, fn quest ->
      badge_count = if Enum.empty?(quest.badges), do: "?", else: Enum.count(quest.badges)
      Map.put(quest, :badge_count, badge_count)
    end)
  end

  # Handle badge details modal
  def handle_event("show_single_badge_details", %{"id" => badge_id}, socket) do
    # Fetch the badge details based on the ID
    badge_detail = Badges.get_badge_with_quest!(badge_id)
    {:noreply, assign(socket, badge_detail: badge_detail, show_single_badge_details: true)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, show_single_badge_details: false)}
  end

  def handle_event("show-content", %{"type" => type}, socket) do
    {:noreply, assign(socket, tab: type)}
  end

  # Handle Quest details modal
  def handle_event("show_quest_details", %{"id" => quest_id}, socket) do
    account_id = socket.assigns.current_account.id

    quest_details =
      Quests.get_quest(quest_id)
      |> Repo.preload([:badges])

    collected_badges_ids = Quests.get_collected_badges_ids_for_quest(account_id, quest_id)

    marked_badges =
      Enum.map(quest_details.badges, fn badge ->
        collected = badge.id in collected_badges_ids
        Map.put(badge, :collected, collected)
      end)

    quest_details = Map.put(quest_details, :badges, marked_badges)

    {:noreply, assign(socket, quest_details: quest_details, show_quest_details: true)}
  end

  def handle_event("quest_details_cancel", _, socket) do
    {:noreply, assign(socket, show_quest_details: false)}
  end

  def handle_event("select-quest", %{"id" => quest_id}, socket) do
    account_id = socket.assigns.current_account.id

    case QuestApiV21.Accounts.update_selected_quest_for_user(account_id, quest_id) do
      {:ok, _account} ->
        # Optionally, fetch updated quest info to refresh the live view or navigate the user
        {:noreply, socket}

      {:error, _reason} ->
        # Handle error, maybe log it or show a message to the user
        {:noreply, socket}
    end
  end

  def handle_event("show-reward-details", %{"id" => reward_id}, socket) do
    # Assuming this function exists to fetch reward details
    reward = QuestApiV21.Rewards.get_reward!(reward_id)

    {:noreply, assign(socket, reward_detail: reward, show_reward_details: true)}
  end

  def handle_event("redeem_reward", %{"id" => reward_id}, socket) do
    reward = Rewards.get_reward!(reward_id)

    case Rewards.redeem_reward_by_slug(reward.organization_id, reward.slug) do
      {:ok, updated_reward} ->
        updated_rewards =
          Enum.map(socket.assigns.rewards, fn reward ->
            if reward.id == updated_reward.id, do: updated_reward, else: reward
          end)

        {:noreply,
         socket
         |> assign(:rewards, updated_rewards)
         |> assign(:show_reward_details, false)}

      {:error, _reason} ->
        {:noreply, socket |> put_flash(:error, "Failed to redeem reward")}
    end
  end

  def handle_event("close-popup", _, socket) do
    {:noreply, assign(socket, show_reward_details: false)}
  end

  def handle_event("close-code-popup", _, socket) do
    {:noreply, assign(socket, show_reward_details: false)}
  end

  # Handle custom event to close the reward modal
  def handle_info(:close_modal, socket) do
    {:noreply, assign(socket, show_reward_details: false)}
  end

  defp generate_qr_code(url) do
    url
    |> EQRCode.encode()
    |> EQRCode.svg(color: "#000", shape: "square", background_color: "#FFF", width: 300)
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= case @live_action do %>
        <% :home -> %>
          <%= home(assigns) %>
        <% :quests -> %>
          <%= quests(assigns) %>
        <% :profile -> %>
          <%= profile(assigns) %>
      <% end %>
    </div>
    """
  end

  def home(assigns) do
    ~H"""
    <div class="relative">
      <div class="fixed w-full left-0 z-40">
        <.live_component
          module={QuestApiV21Web.LiveComponents.HomeNav}
          active_tab={@tab}
          id="home-nav"
        />
      </div>
      <div class="h-20"></div>

      <div class="px-2">
        <%= case assigns.tab do %>
          <% "badges" -> %>
            <.live_component
              module={QuestApiV21Web.LiveComponents.BadgesLive}
              id="badges"
              badge_detail={@badge_detail}
              badges={@badges}
              show_single_badge_details={@show_single_badge_details}
            />
          <% "myquests" -> %>
            <div class="px-2 space mb-12">
              <%= for quest <- @quests_with_completion do %>
                <button
                  phx-click="show_quest_details"
                  phx-value-id={quest.id}
                  class="focus:shadow-inner my-4  transition-all ease-in-out duration-400 rounded-xl w-full"
                >
                  <.live_component
                    class="shadow-xl h-fit"
                    module={QuestApiV21Web.LiveComponents.MyQuestCard}
                    id={"quests-card-#{quest.id}"}
                    completion_bar={true}
                    quest={quest}
                    percentage={quest.completion_percentage}
                  />
                </button>

                <%= if @quest_details do %>
                  <.live_component
                    module={QuestApiV21Web.LiveComponents.QuestDetails}
                    id={"quest-details-modal-#{quest.id}"}
                    show={@show_quest_details}
                    quest_details={@quest_details}
                  />
                <% end %>
              <% end %>
            </div>
          <% "rewards" -> %>
            <%= if @show_reward_details do %>
              <.live_component
                module={QuestApiV21Web.LiveComponents.RedemptionCode}
                id={@reward_detail.id}
                reward={@reward_detail}
              />
            <% end %>

            <div class="pt-8 px-4">
              <%= for reward <- @rewards do %>
                <div
                  phx-click={if reward.redeemed, do: nil, else: "show-reward-details"}
                  phx-value-id={reward.id}
                  class="mx-8 mb-12 mx-auto relative rounded-lg bg-white text-gray-700 ring-1 ring-gray-300 shadow-xl shadow-brand/20"
                >
                  <%= if reward.redeemed do %>
                    <div class="h-full w-full text-xl flex items-center my-auto bg-white/50 rounded-lg absolute uppercase text-center">
                      <p class="w-full bg-brand/90 ring-1 text-white ring-white">redeemed</p>
                    </div>
                  <% end %>
                  <div class="grid grid-cols-12 p-2">
                    <img
                      class="col-span-3 w-20 h-20 flex-shrink rounded-lg ring-1 ring-gray-200 object-cover mr-2"
                      src={reward.quest.quest_image || "/images/questdefault.webp"}
                    />

                    <div class="my-auto col-span-7 ml-1">
                      <h1 class="text-lg truncate">
                        <%= reward.reward_name %>
                      </h1>
                      <p class="text-xs mb-1 text-gray-500 truncate"><%= reward.quest.name %></p>
                      <!--<p class="text-xs font-light truncate"></p>-->
                    </div>
                    <div class="col-span-2 flex items-center">
                      <div class="w-full text-xs rounded-full bg-green-500 ring-1 ring-gray-300 p-1 text-white uppercase text-center">
                        Redeem
                      </div>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
        <% end %>
      </div>
    </div>
    """
  end

  def quests(assigns) do
    ~H"""
    <div class="pb-12 pb-8 text-white">
      <div class="ring-1 ring-gray-400 rounded-b-2xl pb-4 shadow-lg fixed w-full z-30 bg-white">
        <h1 class="pt-4 m-auto text-2xl text-gray-700 w-fit">Find A Quest</h1>
      </div>
      <div class="flex flex-col px-2 pt-20">
        <%= for quest <- @available_quests do %>
          <div phx-click="show_quest_details" phx-value-id={quest.id} class=" mb-8">
            <.live_component
              module={QuestApiV21Web.LiveComponents.QuestCard}
              id={"quests-card-#{quest.id}"}
              completion_bar={nil}
              class={nil}
              quest={quest}
            />
          </div>
          <%= if @quest_details do %>
            <.live_component
              module={QuestApiV21Web.LiveComponents.QuestDetails}
              id={"quest-details-modal-#{quest.id}"}
              show={@show_quest_details}
              quest_details={@quest_details}
            />
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def profile(assigns) do
    ~H"""
    <div>
      <a href="/accounts/settings" class="button">
        <span class="hero-cog-6-tooth w-8 h-8 absolute top-0 right-0 m-4"></span>
      </a>
    </div>
    <div class="pt-12 pb-8">
      <div class="flex justify-center">
        <CoreComponents.avatar name={@account.name || "Nameless"} />
      </div>

      <h1 class="text-center text-3xl font-medium my-4 mb-6">
        <%= @account.name || "Nameless" %>
      </h1>
      <div class="grid grid-cols-3 place-content-center mx-auto h-24 w-72 p-2 rounded-xl ring-2 ring-gray-200">
        <CoreComponents.stats_bubble number={@account.quests_stats} color="violet" text="Quests" />

        <div class="border-x-2 border-gray-300">
          <CoreComponents.stats_bubble number={@account.badges_stats} color="lime" text="Badges" />
        </div>

        <CoreComponents.stats_bubble number={@account.rewards_stats} color="amber" text="Rewards" />
      </div>
    </div>
    <div class="mx-auto w-72">
      <CoreComponents.button phx-click="navigate" phx-window-location="/accounts/settings" class="">
        Account Settings
      </CoreComponents.button>
    </div>
    <!--<div class="w-72 mx-auto rounded-full shadow-md">
      <h1 class="text-center my-4">Share this QR code to your profile</h1>
      <%= raw(@qr_code_svg) %>
    </div>-->
    """
  end
end
