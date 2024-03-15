defmodule QuestApiV21Web.LiveComponents.HomeNav do
  use Phoenix.LiveComponent

  def mount(assigns) do
    {:ok, assigns}
  end

  def render(assigns) do
    ~H"""
    <nav class="grid grid-cols-3 gap-2 w-2/3">
      <button
        class="bg-gradient-to-r from-cyan-200 rounded-full ring-1 ring-slate-400"
        phx-click="show-content"
        phx-value-type="badges">
        Badges
      </button>

      <button
        class="bg-gradient-to-r from-cyan-200 rounded-full ring-1 ring-slate-400"
        phx-click="show-content"
        phx-value-type="myquests">
        Quests
      </button>

      <button
        class="bg-gradient-to-r from-cyan-200 rounded-full ring-1 ring-slate-400"
        phx-click="show-content"
        phx-value-type="rewards">
        Rewards
      </button>
    </nav>
    """
  end
end
