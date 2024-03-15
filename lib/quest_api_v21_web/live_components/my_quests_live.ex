defmodule QuestApiV21Web.LiveComponents.MyQuestsLive do
  use Phoenix.LiveComponent

  def mount(assigns) do

    {:ok, assigns}
  end

  def render(assigns) do

    ~H"""

      <div>
        <%= for quest <- @quests do %>
        <div class="p-6 m-4 mx-auto w-3/4 rounded-md ring-1 ring-slate-700">

          <h1 class="font-bold font-regular">
          <%= quest.name %>
          </h1>
          <p class="text-sm font-sm">
            <%= quest.reward %>
          </p>
        </div>
      <% end %>
    </div>

    """

  end

end
