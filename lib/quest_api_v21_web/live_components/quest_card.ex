defmodule QuestApiV21Web.LiveComponents.QuestCard do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class={"#{@class}relative text-left rounded-lg overflow-hidden shadow-lg cursor-pointer location-card"}>
      <div class="relative rounded-lg overflow-hidden shadow-lg cursor-pointer">
        <img
          src={@quest.quest_image || "/images/questdefault.webp"}
          alt="Location Image"
          class="w-full h-32 object-cover"
        />

        <div class="absolute inset-0 bg-black/80 z-10 flex flex-col justify-between p-4">
          <div class="my-auto">
            <p class="text-gray-200 z-20 font-bold text-3xl relative">
              <%= @quest.name %>
            </p>
            <p class="text-md text-white mb-2">
              <%= if @quest.reward do %>
                <span class="hero-trophy-solid mr-1"></span><%= @quest.reward %>
              <% end %>
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
