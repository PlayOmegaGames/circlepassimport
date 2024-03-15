defmodule QuestApiV21Web.ProfileLive do

  use Phoenix.LiveView
  alias QuestApiV21Web.CoreComponents

  def mount(_params, _session, socket) do
    account = socket.assigns.current_account
    IO.inspect(account)

    {:ok, assign(socket, :account, account)}

  end

  def render(assigns) do

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
