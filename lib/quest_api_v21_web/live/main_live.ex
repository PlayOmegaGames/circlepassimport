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

    quests_with_completion = calculate_completion(quests_list, badges)

    # Split quests into completed and incomplete
    {completed_quests, incomplete_quests} = Enum.split_with(quests_with_completion, fn quest ->
      quest.completion_percentage == 100
    end)

    current_date = Date.utc_today()
    {available_quests, future_quests} = Enum.split_with(quests_list, fn quest ->
      quest.start_date == nil or (quest.start_date && Date.compare(quest.start_date, current_date) != :gt)
    end)



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
        completed_quests: completed_quests,
        incomplete_quests: incomplete_quests,
        available_quests: available_quests_with_badge_count,
        future_quests: future_quests_with_badge_count,
        badge_detail: nil
      )

    {:ok, socket}
  end

  defp calculate_completion(quests, badges) do
    Enum.map(quests, fn quest ->
      quest_badges = Enum.filter(badges, fn badge -> badge.quest_id == quest.id end)
      total_quest_badges = Enum.count(quest.badges)
      user_quest_badges = Enum.count(quest_badges)

      completion_percentage = if total_quest_badges > 0, do: (user_quest_badges / total_quest_badges) * 100, else: 0
      Map.put(quest, :completion_percentage, completion_percentage)
    end)
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


      <.live_component module={QuestApiV21Web.LiveComponents.HomeNav} id="home-nav" />

      <%= case assigns.tab do %>
        <% "badges" -> %>
          <.live_component module={QuestApiV21Web.LiveComponents.BadgesLive} id="badges" badge_detail={@badge_detail} badges={@badges} show_single_badge_details={@show_single_badge_details}/>
        <% "myquests" -> %>
        <.live_component module={QuestApiV21Web.LiveComponents.MyQuestsLive} id="quests" quests={@quests}/>
        <% "rewards" -> %>
          <.live_component module={QuestApiV21Web.LiveComponents.RewardsLive} id="rewards" rewards={@rewards}/>
      <% end %>
    </div>
    """
  end

  def quests(assigns) do
    ~H"""
      <div class="pb-36 text-white">
      <div class="w-full h-20 bg-gradient-to-b rounded-bl-3xl border-b-2 border-l-2 border-gold-300 from-highlight to-accent">
        <h1 class="pt-4 m-auto text-2xl w-fit">Find A Quest</h1>
      </div>

            <div class="px-2 pt-8">
              <div class="flex flex-col space-y-8">

                <%= for quest <- @available_quests do %>

                <.live_component
                  module={QuestApiV21Web.LiveComponents.QuestCard}
                  id={"quests-card-#{quest.id}"}
                  completion = {nil}
                  class={nil}
                  quest= {quest} />

                <% end %>

              </div>
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
