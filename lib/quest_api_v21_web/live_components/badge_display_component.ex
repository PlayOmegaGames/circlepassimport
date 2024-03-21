defmodule QuestApiV21Web.BadgeDisplayComponent do
  use Phoenix.LiveComponent

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="text-white">
      <%= if @error do %>
        <h1 class="text-center text-xl">Badge Not Found</h1>
      <% else %>
        <h3 class="overflow-hidden mr-8 w-full py-4 text-lg font-medium text-center uppercase truncate">
          <%= @badge.name %>
        </h3>
        <img class="w-72 h-80 object-cover ring-2 ring-gold-200 rounded-xl mx-auto" src={@badge.badge_details_image} />

        <div class="w-3/4 mx-auto mt-6 ring-1 flex justify-between ring-slate-700 p-2 truncate rounded-lg">
          <%= if @quest do %>
            <div class="text-sm my-auto">
              <p><span class="font-thin mr-2">Quest:</span><%= @quest.name %></p>
              <p><span class="font-thin mr-2">Reward:</span><%= @quest.reward %></p>
            </div>
          <% else %>
            <div class="text-sm my-auto">
              <p><span class="font-thin truncate mr-2">Quest:</span><%= @badge.quest.name %></p>
              <p><span class="font-thin truncate mr-2">Reward:</span><%= @badge.quest.reward %></p>
            </div>
          <% end %>

          <img class="object-cover w-12 h-12 ring-1 ring-gold-100 rounded-full" src={@badge.badge_image} />
        </div>
      <% end %>
    </div>
    """
  end

end
