defmodule QuestApiV21Web.HomeLive do
  use Phoenix.LiveView

  alias QuestApiV21.Badges
  alias QuestApiV21.Quests
  alias QuestApiV21.Rewards

  def mount(_params, _session, socket) do
    account_id = socket.assigns.current_account.id

    {:ok, badges} = Badges.get_badges_for_account(account_id)
    {:ok, quests} = Quests.get_quests_for_account(account_id)
    {:ok, rewards} = Rewards.get_rewards_for_account(account_id)


    socket =
      socket
      |> assign(:badges, badges)
      |> assign(:quests, quests)
      |> assign(:rewards, rewards)
      |> assign(:current_view, "badges")

    {:ok, socket}
  end

  def handle_event("show-content", %{"type" => type}, socket) do
    {:noreply, assign(socket, current_view: type)}
  end


  def render(assigns) do

    ~H"""
      <div class="px-2">
        <%= live_component QuestApiV21Web.LiveComponents.HomeNav, id: "home-nav" %>

        <%= if @current_view == "badges" do %>
          <%= live_component @socket, QuestApiV21Web.LiveComponents.BadgesLive, id: "badges", badges: @badges %>
          <% end %>

        <%= if @current_view == "quests" do %>
          <%= live_component QuestApiV21Web.LiveComponents.QuestLive, id: "quests", quests: @quests %>
        <% end %>

        <%= if @current_view == "rewards" do %>
        <%= live_component QuestApiV21Web.LiveComponents.RewardsLive, id: "rewards", rewards: @rewards %>
      <% end %>

      </div>
    """

  end
end
