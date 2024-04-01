defmodule QuestApiV21Web.LiveComponents.HomeNav do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <nav class="grid grid-cols-3 gap-1.5 pt-8 pb-4 mb-4 w-11/12 mx-auto text-gray-600 shadow-xs border-b-2 border-gray-300/[0.50]">
      <button
        class={"rounded-full ring-1 transition-all ease-in-out ring-slate-300 bg-gradient-to-r to-white  from-contrast #{if @active_tab == "badges", do: "outline outline-1 text-gray-800", else: ""}"}
        phx-click="show-content"
        phx-value-type="badges"
      >
        Badges
      </button>

      <button
        class={" rounded-full ring-1 transition-all ease-in-out via-contrast ring-slate-300 bg-white	 #{if @active_tab == "myquests", do: "outline outline-1 text-gray-800", else: ""}"}
        phx-click="show-content"
        phx-value-type="myquests"
      >
        My Quests
      </button>

      <button
        class={"rounded-full ring-1 transition-all ease-in-out ring-slate-300 bg-gradient-to-l to-white from-contrast #{if @active_tab == "rewards", do: "outline outline-1 text-gray-800", else: ""}"}
        phx-click="show-content"
        phx-value-type="rewards"
      >
        Rewards
      </button>
    </nav>
    """
  end
end
