defmodule QuestApiV21Web.LiveComponents.RewardsLive do
  use Phoenix.LiveComponent

  def mount(assigns) do

    {:ok, assigns}
  end

  def render(assigns) do

    ~H"""

      <div>
        <%= for reward <- @rewards do %>
        <div
          class={"m-4 p-4 mx-auto w-3/4 rounded-md bg-accent ring-2 ring-gold-200 shadow-xl shadow-white"}>

          <h1 class="font-bold text-white text-center">
          <%= reward.reward_name %>
          </h1>
        </div>
      <% end %>
    </div>

    """

  end

end
