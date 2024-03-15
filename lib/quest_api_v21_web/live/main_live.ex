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
        tab: "badges",
        rewards: rewards,
        account: account,
        current_view: "home",
        available_quests: available_quests_with_badge_count,
        future_quests: future_quests_with_badge_count
      )

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    tab = params["tab"] || "badges" # Default to "badges" tab if none specified

    socket =
      socket
      |> assign(tab: tab)
      |> case do
        # Optionally, perform additional actions based on the tab, like setting `live_action`
        ^socket -> assign(socket, live_action: :home)
        _ -> socket
      end

    {:noreply, socket}
  end


  defp calculate_badge_count(quests) do
    Enum.map(quests, fn quest ->
      badge_count = if Enum.empty?(quest.badges), do: "?", else: Enum.count(quest.badges)
      Map.put(quest, :badge_count, badge_count)
    end)
  end

  def handle_event("show-content", %{"type" => type}, socket) do
    {:noreply, assign(socket, tab: type)}
  end



  def render(assigns) do
    ~H"""
      <div>
        <%= navbar(assigns) %>
        <%= case @current_view do %>
          <% "home" -> %>
            <%= home(assigns) %>
          <% "quests" -> %>
            <%= quests(assigns) %>
          <% "profile" -> %>
            <%= profile(assigns) %>
        <% end %>
      </div>
    """
  end


  defp navbar(assigns) do
    current_view = assigns.current_view
    ~H"""
      <!-- Bottom Nav -->
      <div class="fixed bottom-0 w-full bg-gradient-to-b from-indigo-100 to-contrast">
        <div class="grid grid-cols-3 justify-items-center">
          <.link patch={"/home"} class={" #{if @current_view == "home", do: "text-gray-900"} py-2 w-14 h-14 text-xs"}>
            <div>
              <!-- Home Icon HTML -->
              <span class={"ml-4 w-6 h-6 hero-home#{if current_view == "home", do: "-solid"}"}></span>
              <p class={"text-center #{if current_view == "home", do: "font-bold", else: "font-base"}"}>Home</p>
            </div>
          </.link>

          <.link patch="/quests" class={" #{if @current_view == "quests", do: "text-gray-900"} py-2 w-14 h-14 text-xs"}>
            <div>
              <!-- Quests Icon HTML -->
              <!-- SVG or other icon for Quests -->
              <p class={"text-center #{if current_view == "quests", do: "font-bold", else: "font-base"}"}>Quests</p>
            </div>
          </.link>

          <.link patch="/profile" class={" #{if @current_view == "profile", do: "text-gray-900"} py-2 w-14 h-14 text-xs"}>
            <div>
              <!-- Profile Icon HTML -->
              <span class={"ml-4 w-6 h-6 hero-user#{if current_view == "profile", do: "-solid"}"}></span>
              <p class={"text-center #{if current_view == "profile", do: "font-bold", else: "font-base"}"}>Profile</p>
            </div>
          </.link>
        </div>
      </div>
    """
  end


  defp home(assigns) do
    ~H"""
    <div class="px-2">
      <.live_component module={QuestApiV21Web.LiveComponents.HomeNav} id="home-nav" />

      <%= case @tab do %>
        <% "badges" -> %>
          <.live_component module={QuestApiV21Web.LiveComponents.BadgesLive} id="badges" badges={@badges}/>
        <% "myquests" -> %>
        <.live_component module={QuestApiV21Web.LiveComponents.MyQuestsLive} id="quests" quests={@quests}/>
        <% "rewards" -> %>
          <.live_component module={QuestApiV21Web.LiveComponents.RewardsLive} id="rewards" rewards={@rewards}/>
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
