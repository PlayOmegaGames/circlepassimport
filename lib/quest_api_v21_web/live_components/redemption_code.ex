defmodule QuestApiV21Web.LiveComponents.RedemptionCode do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div
        id="redemption-code-popup"
        class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50"
      >
        <div class="relative top-40 mx-auto pb-12 p-2 pt-8 border w-3/4 shadow-lg rounded-md bg-white ring-1 ring-slate-600">
          <h2 class="text-xl text-center font-thin text-gray-700">Claim Your Reward:</h2>
          <p class="font-medium text-lg pt-4 pb-8 text-center">
            <%= @reward.reward_name %>
          </p>

          <div class="justify-center flex">
            <button
              id="redeem-btn"
              class="w-16 h-16 ring-1 relative rounded-full ring-gray-400 shadow-lg"
              phx-click="redeem_reward"
              phx-value-id={@reward.id}
            >
              <img
                id="check-image"
                class="z-50 opacity-90 top-2 left-2 absolute rounded-full w-12 h-12"
                src="/images/check.png"
              />
              <img
                class="absolute rounded-full top-2 opacity-90 left-2 w-12 h-12"
                src="/images/check.gif"
              />
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
