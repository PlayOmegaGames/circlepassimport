defmodule QuestApiV21Web.LiveComponents.MyQuestCard do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class={"#{@class}relative text-left rounded-lg overflow-hidden shadow-lg cursor-pointer location-card"}>
      <h3 class="text-xl font-light text-gray-600 max-w-full truncate"><%= @quest.name %></h3>
      <p class="text-md text-brand mb-1">
        <%= if @quest.reward do %>
          <span class="hero-trophy-solid"></span><%= @quest.reward %>
        <% end %>
      </p>

      <div class="relative rounded-lg overflow-hidden shadow-lg cursor-pointer">
        <img
          src={@quest.quest_image || "/images/questdefault.webp"}
          alt="Location Image"
          class="w-full h-32 object-cover"
        />

        <div
          class="absolute inset-0 bg-black/70 z-10 flex flex-col justify-between p-4"
          style={"width: #{@percentage}%;"}
        >
          <div class="text-gray-200 z-20 font-medium text-6xl my-auto relative">
            <%= @percentage %>%
          </div>
        </div>
      </div>
    </div>
    """
  end
end
