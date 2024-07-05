defmodule QuestApiV21Web.LiveComponents.HomeNav do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <nav class="grid grid-cols-3 gap-1.5 py-5 bg-gray-100 px-2 w-full mx-auto text-gray-600 shadow-xs border-b-2 border-gray-300/[0.50]">
      <button
        class={"rounded-full ring-1 transition-all ease-in-out ring-slate-400 bg-white  #{if @active_tab == "badges", do: " text-gray-800 font-medium shadow-md shadow-brand/30", else: "shadow-black/20"}"}
        phx-click="show-content"
        phx-value-type="badges"
      >
        Badges
      </button>

      <button
        class={" rounded-full ring-1 transition-all ease-in-out via-contrast ring-slate-500 bg-white 	 #{if @active_tab == "myquests", do: " text-gray-800 font-medium shadow-md shadow-brand/30", else: "shadow-black/20"}"}
        phx-click="show-content"
        phx-value-type="myquests"
      >
        My Quests
      </button>

      <button
        class={"rounded-full ring-1 transition-all ease-in-out ring-slate-500 bg-white  #{if @active_tab == "rewards", do: " text-gray-800 font-medium shadow-md shadow-brand/30", else: "shadow-black/20"}"}
        phx-click="show-content"
        phx-value-type="rewards"
      >
        Rewards
      </button>
    </nav>
    """
  end
end
