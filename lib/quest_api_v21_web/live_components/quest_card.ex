defmodule QuestApiV21Web.LiveComponents.QuestCard do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class={"#{@class} overflow-hidden bg-accent h-48 rounded-xl ring-1 ring-white/[0.40] text-white"}>
      <div class="flex-col justify-center py-4 pl-4">
        <div class="flex justify-between">
          <div class="flex pt-4 -space-x-8">
            <%= for quest_badge <- Enum.take(@quest.badges, 3) do %>
              <img
                class="inline-block relative z-20 w-16 h-16 rounded-full ring-1 object-cover ring-white"
                src={quest_badge.badge_image}
                alt={quest_badge.name}
              />
            <% end %>
            <div class="pl-8 text-xs text-gold-200">+<%= length(@quest.badges) %></div>
          </div>

          <div class="overflow-hidden ml-2 w-full">
            <h3 class="mb-4 font-light text-center truncate ... text-md"><%= @quest.name %></h3>
            <h4 class="px-8 w-full text-center uppercase truncate bg-highlight">
              <%= @quest.reward %>
            </h4>
          </div>
        </div>

        <%= if @completion_bar do %>
          <div class="pt-4 mx-auto w-3/4">
            <div class="rounded-full bg-indigo-300/[0.30]">
              <div style={"width: #{@percentage}%;"} class="z-10 h-1 bg-gold-300"></div>
            </div>
            <span class="text-xs "><%= @percentage %>%</span>
          </div>
        <% else %>
          <p class="overflow-hidden px-4 pt-4 text-xs font-light"><%= @quest.description %></p>
        <% end %>
      </div>
    </div>
    """
  end
end
