defmodule QuestApiV21Web.PublicProfileLive do
  use Phoenix.LiveView
  alias QuestApiV21.Accounts
  alias QuestApiV21Web.CoreComponents

  def handle_params(%{"id" => id}, _uri, socket) do
    account = Accounts.find_account_by_id(id)

    # Update the socket with the fetched account data
    socket = assign(socket, account: account)

    # Return {:noreply, socket} for handle_params
    {:noreply, socket}
  end

  def mount(_params, _session, socket) do
    # Initialize the socket with account data as nil
    socket = assign(socket, account: nil)

    {:ok, assign(socket, :background_color, "bg-gradient-to-t from-violet-300 to-violet-100")}
  end

  def render(assigns) do
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

      <div class="flex w-full justify-center space-y-8 mt-8">
        <div class="w-72">
          <p class="text-gray-800 text-lg font-medium mb-2">Email</p>
          <div class="ring-1 w-full ring-gold-200 border-2 border-gold-400 rounded-xl shadow-xl p-3 text-gray-700">
            <a href={"mailto:#{@account.email}"} class="flex-grow">
              <p class="flex justify-center truncate">
                <span class="w-6 h-6 hero-envelope mr-2"></span>
                <%= @account.email %>
              </p>
            </a>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
