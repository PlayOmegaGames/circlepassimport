defmodule QuestApiV21Web.LiveComponents.BadgesLive do
  use Phoenix.LiveComponent

  def mount(assigns) do

    {:ok, assigns}
  end

  def render(assigns) do

    ~H"""

    <div>
      <div class="grid grid-cols-3">
        <%= for badge <- @badges do %>
          <div class="m-4">
            <img
              class="object-cover w-20 h-20 rounded-full ring-2 ring-gray-200 shadow-md shadow-gray-500"
              src={badge.badge_image}
              alt="Badge image"
            />
            <p class="w-24 text-center truncate">
              <%= badge.name %>
            </p>
          </div>
        <% end %>
      </div>
    </div>

    """

  end

end
