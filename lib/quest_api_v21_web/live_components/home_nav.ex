defmodule QuestApiV21Web.LiveComponents.HomeNav do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <nav class="grid grid-cols-3 gap-2 w-2/3 text-gray-800">
      <button
        class="bg-gradient-to-r rounded-full ring-1 from-contrast ring-slate-400"
        phx-click="show-content"
        phx-value-type="badges">
        Badges
      </button>

      <button
        class="bg-gradient-to-r from-white to-white rounded-full ring-1 via-contrast ring-slate-400"
        phx-click="show-content"
        phx-value-type="myquests">
        Quests
      </button>

      <button
        class="bg-gradient-to-l rounded-full ring-1 from-contrast ring-slate-400"
        phx-click="show-content"
        phx-value-type="rewards">
        Rewards
      </button>
    </nav>
    """
  end
end
