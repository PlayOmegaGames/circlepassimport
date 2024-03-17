defmodule QuestApiV21Web.LiveComponents.QuestCard do
  use Phoenix.LiveComponent

  def render(assigns) do

    ~H"""
    <div class={"#{@class} overflow-hidden bg-accent h-48 rounded-xl ring-1 ring-white/[0.40] text-white"}>
      <div class="flex-col justify-center py-4 pl-4">
        <div class="flex justify-between">
          <div class="flex pt-4 -space-x-8">
            <img class="inline-block relative z-20 w-16 h-16 rounded-full ring-2 ring-white" src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80" alt="">
            <img class="inline-block relative z-10 w-16 h-16 rounded-full ring-2 ring-white" src="https://images.unsplash.com/photo-1550525811-e5869dd03032?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80" alt="">
            <img class="inline-block relative z-0 w-16 h-16 rounded-full ring-2 ring-white" src="https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2.25&w=256&h=256&q=80" alt="">
            <div class="pl-8 text-xs text-gold-200">+<%= @quest.badge_count %></div>
          </div>

          <div class="overflow-hidden ml-2 w-full">
            <h3 class="mb-4 font-light text-center truncate ... text-md"> <%= @quest.name %></h3>
            <h4 class="px-6 w-full text-center uppercase truncate bg-highlight"><%= @quest.reward %></h4>
          </div>
        </div>

        <%= if @completion do %>
          <div class="pt-4 mx-auto w-3/4">
              <div class="rounded-full bg-indigo-300/[0.30]">
                <div style={"width: #{@completion}%;"} class="z-10 h-1 bg-gold-300"></div>
              </div>
          </div>
        <% else %>
        <p class="overflow-hidden px-4 pt-4 text-xs font-light"><%= @quest.description %></p>
        <% end %>


      </div>
    </div>
    """

  end



end
