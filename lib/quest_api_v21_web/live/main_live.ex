defmodule QuestApiV21Web.MainLive do
  use Phoenix.LiveView
  alias QuestApiV21.{Badges, Quests, Rewards}
  alias QuestApiV21Web.CoreComponents

  def mount(_params, _session, socket) do
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
        available_quests: available_quests_with_badge_count,
        future_quests: future_quests_with_badge_count
      )

    {:ok, socket}
  end

  defp calculate_badge_count(quests) do
    Enum.map(quests, fn quest ->
      badge_count = if Enum.empty?(quest.badges), do: "?", else: Enum.count(quest.badges)
      Map.put(quest, :badge_count, badge_count)
    end)
  end

  def handle_event("show-content", %{"type" => type}, socket) do
    {:noreply, assign(socket, current_view: type)}
  end




  defp home(assigns) do
    ~H"""
    <div class="px-2">
      <%= live_component QuestApiV21Web.LiveComponents.HomeNav, id: "home-nav" %>

      <%= case @current_view do %>
        <% "badges" -> %>
          <%= live_component QuestApiV21Web.LiveComponents.BadgesLive, id: "badges", badges: @badges %>
        <% "quests" -> %>
          <%= live_component QuestApiV21Web.LiveComponents.QuestLive, id: "quests", quests: @quests %>
        <% "rewards" -> %>
          <%= live_component QuestApiV21Web.LiveComponents.RewardsLive, id: "rewards", rewards: @rewards %>
      <% end %>
    </div>
    """
  end

  defp profile(assigns) do
    ~H"""
    <div class="pb-8 mt-12 bg-white border-b-2 border-slate-200">
      <div class="flex justify-center">
      <CoreComponents.avatar name={@account.name || "nameless"} class="mx-auto border-2 shadow-xl border-slate-900" />
      </div>
      <p class="mt-4 text-xl text-center">
        <%= @account.name %>
      </p>

      <div class="grid grid-cols-3 place-content-center mx-auto mt-4 w-10/12">
      <CoreComponents.stats_bubble number={@account.quests_stats} color="violet" text="Quests" />

        <div class="border-x-2 border-slate-300">
        <CoreComponents.stats_bubble number={@account.badges_stats} color="lime" text="Badges" />
        </div>

        <CoreComponents.stats_bubble number={@account.rewards_stats} color="amber" text="Rewards" />
      </div>
    </div>

    <div class="flex items-center h-80 bg-light-blue">
      <div class="mb-20 w-full">
       <CoreComponents.find_quests />
      </div>
    </div>
    """
  end

  def quests(assigns) do
    ~H"""
    <div class="px-2">
          <div>
            <div class="available-quests">
              <h2>Available Quests</h2>
              <%= for quest <- @available_quests do %>
                <p><%= quest.name %> - Badges: <%= quest.badge_count %></p>
              <% end %>
            </div>
            <div class="future-quests">
              <h2>Future Quests</h2>
              <%= for quest <- @future_quests do %>
                <p><%= quest.name %> - Badges: <%= quest.badge_count %></p>
              <% end %>
            </div>
          </div>
    </div>
    """
  end

end
