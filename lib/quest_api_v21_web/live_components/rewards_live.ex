defmodule QuestApiV21Web.LiveComponents.RewardsLive do
  use Phoenix.LiveComponent

  def mount(assigns) do

    {:ok, assigns}
  end

  def render(assigns) do

    ~H"""

      <div>
        <%= for reward <- @rewards do %>
        <div class="p-6 m-4 mx-auto w-3/4 rounded-md ring-1 ring-slate-700">

          <h1 class="font-bold font-regular">
          <%= reward.reward_name %>
          </h1>
          <p class="text-sm font-sm">TEST
          </p>
        </div>
      <% end %>
    </div>

    """

  end

end
