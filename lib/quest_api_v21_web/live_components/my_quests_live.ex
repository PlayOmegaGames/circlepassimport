defmodule QuestApiV21Web.LiveComponents.MyQuestsLive do
  use Phoenix.LiveComponent

  def mount(assigns) do
    {:ok, assigns}
  end

  def render(assigns) do
    ~H"""
    <div class="px-2 ">
      <%= for quest <- @quests do %>
        <button phx-click="select-quest" phx-value-id={quest.id} class="w-full">
          <.live_component
            class="shadow-xl h-fit"
            module={QuestApiV21Web.LiveComponents.QuestCard}
            id={"quests-card-#{quest.id}"}
            completion_bar={true}
            percentage={50}
            quest={quest}
            />
        </button>
      <% end %>
    </div>
    """
  end


end
