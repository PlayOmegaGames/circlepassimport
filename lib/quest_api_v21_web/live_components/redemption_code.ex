defmodule QuestApiV21Web.LiveComponents.RedemptionCode do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id="redemption-code-popup"
      class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50"
      phx-click="close-popup"
    >
      <div class="relative top-40 mx-auto pb-8 p-2 py-4 border w-3/4 shadow-lg rounded-md bg-white ring-1 ring-slate-600">
        <h2 class="text-lg text-center font-medium">Your Redemption Code</h2>
        <p class="bg-gray-200 rounded-full ring-1 ring-green-500 pl-2 mt-2 py-1">
          <%= @reward.slug %>
        </p>
      </div>
    </div>
    """
  end
end
