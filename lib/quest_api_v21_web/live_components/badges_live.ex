defmodule QuestApiV21Web.LiveComponents.BadgesLive do
  use Phoenix.LiveComponent

  def mount(assigns) do
    {:ok, assigns}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="grid grid-cols-2 gap-8 px-3">
        <%= for badge <- @badges do %>
          <.live_component
            module={QuestApiV21Web.LiveComponents.BadgeTabDetails}
            id={"badge-details-#{badge.id}"}
            show={@show_single_badge_details}
            badge={@badge_detail}
          />

          <div class="" phx-click="show_single_badge_details" phx-value-id={badge.id}>
            <img
              class="object-cover w-full h-auto rounded-full ring-2 shadow-lg ring-gold-100"
              src={badge.badge_image}
              alt="Badge image"
            />

          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
