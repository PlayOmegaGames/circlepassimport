defmodule QuestApiV21Web.LiveComponents.BadgesLive do
  use Phoenix.LiveComponent

  def mount(assigns) do
    {:ok, assigns}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="grid grid-cols-3 gap-x-4 gap-y-8 px-6 pt-6">
        <%= for badge <- @badges do %>
          <.live_component
            module={QuestApiV21Web.LiveComponents.BadgeTabDetails}
            id={"badge-details-#{badge.id}"}
            show={@show_single_badge_details}
            badge={@badge_detail}
          />

          <div class="" phx-click="show_single_badge_details" phx-value-id={badge.id}>
            <img
              class="object-cover h-24 w-24 rounded-full ring-2 shadow-lg ring-gray-300"
              src={badge.badge_image}
              alt="Badge image"
            />
            <p class="mt-2 w-24 text-xs text-center text-gray-700 truncate">
              <%= badge.name %>
            </p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
