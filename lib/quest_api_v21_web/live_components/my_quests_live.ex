defmodule QuestApiV21Web.LiveComponents.MyQuestsLive do
  use Phoenix.LiveComponent

  def mount(assigns) do

    {:ok, assigns}
  end

  def render(assigns) do

    ~H"""

      <div class="px-4 pb-52 mt-6 space-y-8">
        <h1 class="text-xl text-center">Active Quests</h1>
        <%= for quest <- @quests do %>
        <.live_component
          class="shadow-xl h-fit"
          module={QuestApiV21Web.LiveComponents.QuestCard}
          id={"quests-card-#{quest.id}"}
          completion = "test"
          quest= {quest} />
      <% end %>
    </div>

    """

  end

end
