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


        <.live_component module={QuestApiV21Web.LiveComponents.BadgeTabDetails} id={"badge-details-#{badge.id}"} show={@show_single_badge_details} badge={@badge_detail} />

        <div class="m-4 w-20 h-20" phx-click="show_single_badge_details" phx-value-id={badge.id}>
        <img
              class="object-cover w-full h-full rounded-full ring-2 shadow-lg ring-gold-100"
              src={badge.badge_image}
              alt="Badge image"
            />
            <p class="mt-2 w-24 text-xs text-center truncate">
              <%= badge.name %>
            </p>
          </div>
        <% end %>
      </div>
    </div>

    """

  end

end
