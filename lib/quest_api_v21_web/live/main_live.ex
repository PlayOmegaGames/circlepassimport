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
        future_quests: future_quests_with_badge_count
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
    IO.inspect(assigns.tab, label: "Current tab")
    ~H"""
    <div class="px-2">

      <.live_component module={QuestApiV21Web.LiveComponents.HomeNav} id="home-nav" />

      <%= case assigns.tab do %>
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

  def quests(assigns) do
    ~H"""
      <div class="pb-36 text-white">
      <div class="w-full h-20 bg-gradient-to-b rounded-bl-3xl border-b-2 border-l-2 border-gold-300 from-highlight to-accent">
        <h1 class="pt-4 m-auto text-2xl w-fit">Find A Quest</h1>
      </div>
            <div class="px-2 pt-8">
              <div class="flex flex-col space-y-8">

                <%= for quest <- @available_quests do %>


                <div class="overflow-hidden bg-accent h-48 rounded-xl ring-1 ring-white/[0.40] border-gold-300">
                <div class="flex-col justify-center py-4 pl-4">
                  <div class="flex justify-between">
                    <div class="flex pt-4 -space-x-8">
                      <img class="inline-block relative z-20 w-16 h-16 rounded-full ring-2 ring-white" src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80" alt="">
                      <img class="inline-block relative z-10 w-16 h-16 rounded-full ring-2 ring-white" src="https://images.unsplash.com/photo-1550525811-e5869dd03032?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80" alt="">
                      <img class="inline-block relative z-0 w-16 h-16 rounded-full ring-2 ring-white" src="https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2.25&w=256&h=256&q=80" alt="">
                      <div class="pl-8 text-xs text-gold-200">+<%= quest.badge_count %></div>
                    </div>

                    <div class="overflow-hidden ml-2 w-full">
                      <h3 class="mb-4 font-light text-center truncate ... text-md"><%= quest.name %></h3>
                      <h4 class="px-1 w-full text-center uppercase truncate bg-highlight"><%= quest.reward %></h4>
                    </div>
                  </div>
                  <p class="overflow-hidden px-4 pt-4 text-xs font-light"><%= quest.description %></p>
                  </div>
                </div>
                <% end %>

              </div>
            </div>
      </div>
    """
  end


  def profile(assigns) do
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

end
