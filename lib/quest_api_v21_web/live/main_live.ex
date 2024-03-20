defmodule QuestApiV21Web.MainLive do
  use Phoenix.LiveView
  alias QuestApiV21.{Badges, Quests, Rewards}
  alias QuestApiV21Web.CoreComponents

  def mount(_params, _session, socket) do

    #IO.inspect(socket.assigns.live_action, label: "mount live_action")

    account_id = socket.assigns.current_account.id

    {:ok, badges} = Badges.get_badges_for_account(account_id)
    {:ok, quests} = Quests.get_quests_for_account(account_id)
    {:ok, rewards} = Rewards.get_rewards_for_account(account_id)
    account = socket.assigns.current_account
    quests_list = Quests.list_public_quests()


    current_date = Date.utc_today()
    {available_quests, future_quests} = Enum.split_with(quests_list, fn quest ->
      quest.start_date == nil or (quest.start_date && Date.compare(quest.start_date, current_date) != :gt)
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
        show_single_badge_details: false,
        current_view: "home",
        tab: "badges",
        available_quests: available_quests_with_badge_count,
        future_quests: future_quests_with_badge_count,
        badge_detail: nil,
        quests_with_completion: quests_with_completion,
        show_single_badge_details: false,
        show_reward_details: false
      )

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    tab = params["tab"] || "badges" # Default to "badges" tab if none specified

    background_color = case socket.assigns.live_action do
      :quests -> "bg-background-800"
      _ -> "false"
    end
    IO.inspect(background_color)
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
          completion_percentage = if total_badges > 0,
          do: round((earned_badges / total_badges) * 100),
          else: 0
          # Return the quest map with the completion percentage added
          Map.put(quest, :completion_percentage, completion_percentage)
      end
    end)
  end


  defp calculate_badge_count(quests) do
    Enum.map(quests, fn quest ->
      badge_count = if Enum.empty?(quest.badges), do: "?", else: Enum.count(quest.badges)
      Map.put(quest, :badge_count, badge_count)
    end)
  end

  def handle_event("show-content", %{"type" => type}, socket) do
    IO.inspect(type, label: "Show Content Type")
    {:noreply, assign(socket, tab: type)}
  end

  def handle_event("show_single_badge_details", %{"id" => badge_id}, socket) do
    badge_detail = Badges.get_badge!(badge_id) # Fetch the badge details based on the ID
    {:noreply, assign(socket, badge_detail: badge_detail, show_single_badge_details: true)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, show_single_badge_details: false)}
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
    reward = QuestApiV21.Rewards.get_reward!(reward_id) # Assuming this function exists to fetch reward details

    {:noreply, assign(socket, reward_detail: reward, show_reward_details: true)}
  end

  def handle_event("close-popup", _, socket) do
    {:noreply, assign(socket, show_reward_details: false)}
  end

  def handle_event("close-code-popup", _, socket) do
    {:noreply, assign(socket, show_reward_details: false)}
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
    <div class="px-2">


      <.live_component module={QuestApiV21Web.LiveComponents.HomeNav} active_tab={@tab} id="home-nav" />

      <%= case assigns.tab do %>
        <% "badges" -> %>
          <.live_component module={QuestApiV21Web.LiveComponents.BadgesLive} id="badges" badge_detail={@badge_detail} badges={@badges} show_single_badge_details={@show_single_badge_details}/>
        <% "myquests" -> %>
            <div class="px-2 space-y-4 mb-12">
            <%= for quest <- @quests_with_completion do %>
              <button phx-click="select-quest" phx-value-id={quest.id} class="focus:outline-4 focus:outline-double focus:shadow-lg focus:shadow-white transition-all ease-in-out duration-400 rounded-xl w-full">
                <.live_component
                  class="shadow-xl h-fit"
                  module={QuestApiV21Web.LiveComponents.QuestCard}
                  id={"quests-card-#{quest.id}"}
                  completion_bar={true}
                  quest={quest}
                  percentage={quest.completion_percentage}
                  />
              </button>
            <% end %>
          </div>
        <% "rewards" -> %>
        <%= if @show_reward_details do %>
        <.live_component module={QuestApiV21Web.LiveComponents.RedemptionCode} id={@reward_detail.id} reward={@reward_detail} />
        <% end %>

        <%= for reward <- @rewards do %>

        <%= if reward.redeemed do %>
          <div
            phx-value-id={reward.id}
            class={"m-8 mx-auto w-10/12 rounded-md bg-gray-700 text-white ring-2 ring-gray-500 opacity-80"}>

          <div class="flex p-2">
          <img src="/images/present.png" class="grayscale w-12 h-12 flex-shrink mr-2" />
            <div>
              <h1 class="font-regular text-white text-center text-sm flex truncate">
              <%= reward.reward_name %>
              </h1>
                <p class="text-xs font-light truncate"><%= reward.organization.name %></p>
            </div>
          </div>
            <div class="w-full bg-gray-600 text-sm rounded-b-lg text-center py-1">Claimed</div>
            </div>
        <% else %>
          <div
            phx-click="show-reward-details"
            phx-value-id={reward.id}
            class={"m-8 mx-auto w-10/12 rounded-md bg-accent text-white ring-2 ring-gold-300 shadow-xl shadow-white"}>

          <div class="flex p-2">
          <img src="/images/present.png" class="w-12 h-12 flex-shrink mr-2" />
            <div>
              <h1 class="font-regular text-white text-center text-sm flex truncate">
              <%= reward.reward_name %>
              </h1>
                <p class="text-xs font-light truncate"><%= reward.organization.name %></p>
            </div>
          </div>
            <div class="w-full bg-highlight text-sm rounded-b-lg text-center py-1">Claim Reward</div>
            </div>
          <% end %>
        <% end %>
      <% end %>
    </div>
    """
  end

  def quests(assigns) do
    ~H"""
      <div class="pb-12 pb-8 text-white">
      <div class="w-full h-20 bg-gradient-to-b rounded-bl-3xl border-b-2 border-l-2 border-gold-300 from-highlight to-accent">
        <h1 class="pt-4 m-auto text-2xl w-fit">Find A Quest</h1>
      </div>

              <div class="flex flex-col px-2 space-y-4 mb-12 pt-8">

                <%= for quest <- @available_quests do %>

                <.live_component
                  module={QuestApiV21Web.LiveComponents.QuestCard}
                  id={"quests-card-#{quest.id}"}
                  completion_bar = {nil}
                  class={nil}
                  quest= {quest}
                  />

                <% end %>

              </div>
      </div>
    """
  end


  def profile(assigns) do
    ~H"""
      <div class="pt-12 pb-8">
        <div class="flex justify-center">
        <CoreComponents.avatar name={@account.name || "Nameless"} />
        </div>

          <h1 class="text-center text-3xl font-medium my-4">
            <%= @account.name || "Nameless" %>
          </h1>
          <div
            class="grid grid-cols-3 place-content-center mx-auto h-32 w-72 p-2 bg-cover"
            style="background-image: url(/images/profilegold.png)"
            >
            <CoreComponents.stats_bubble number={@account.quests_stats} color="violet" text="Quests" />

          <div class="border-x-2 border-gold-300">
            <CoreComponents.stats_bubble number={@account.badges_stats} color="lime" text="Badges" />
          </div>

            <CoreComponents.stats_bubble number={@account.rewards_stats} color="amber" text="Rewards" />
        </div>
      </div>

    """
  end

end
