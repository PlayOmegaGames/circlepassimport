defmodule QuestApiV21Web.QuestsLive do
  use Phoenix.LiveView
  require Logger

  def mount(_params, _session, socket) do
    quests = QuestApiV21.Quests.list_public_quests()
    current_date = Date.utc_today()

    {available_quests, future_quests} = Enum.split_with(quests, fn quest ->
      quest.start_date == nil or
      (quest.start_date && Date.compare(quest.start_date, current_date) != :gt)
    end)

    available_quests_with_badge_count = calculate_badge_count(available_quests)
    future_quests_with_badge_count = calculate_badge_count(future_quests)

    socket =
      socket
      |> assign(:available_quests, available_quests_with_badge_count)
      |> assign(:future_quests, future_quests_with_badge_count)
      |> assign(:camera, true)

    {:ok, socket}
  end

  defp calculate_badge_count(quests) do
    Enum.map(quests, fn quest ->
      badge_count = if Enum.empty?(quest.badges), do: "?", else: Enum.count(quest.badges)
      Map.put(quest, :badge_count, badge_count)
    end)
  end

  def render(assigns) do
    ~H"""
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
    """
  end
end
