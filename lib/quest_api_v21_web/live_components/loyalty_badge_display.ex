defmodule QuestApiV21Web.LoyaltyBadgeDisplay do
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
        <img
          class="w-72 h-80 object-cover ring-2 ring-gold-200 rounded-xl mx-auto"
          src={@badge.badge_details_image}
        />

        <div class="w-3/4 mx-auto mt-6 ring-1 flex ring-slate-700 p-2 truncate rounded-lg">
          <img
            class="object-cover w-12 h-12 ring-1 ring-gold-100 rounded-full mr-2"
            src={@badge.badge_image}
          />

          <%= if @quest do %>
            <div class="text-sm my-auto">
              <p><span class="font-thin mr-2">Quest:</span><%= @quest.name %></p>
              <p><span class="font-thin mr-2">Next Reward:</span><%= @next_reward %></p>
            </div>
          <% else %>
            <div class="text-sm my-auto">
              <p><span class="font-thin truncate mr-2">Quest:</span><%= @badge.quest.name %></p>
              <p>
                <%= if @next_reward do %>
                  <span class="font-thin truncate mr-2">Next Reward:</span> <%= @next_reward %>
                <% else %>
                  Completed
                <% end %>
              </p>
            </div>
          <% end %>
        </div>
        <div class="flex justify-center">
          <div class="h-4 w-fit">
            <!-- Countdown Timer Placeholder -->
            <%= if @next_scan_date > 0 do %>
              <span class="hero-clock h-4 w-4"></span>
              <span
                id="countdown-timer"
                data-next-scan-date={@next_scan_date}
                phx-hook="CountdownTimer"
                class="text-center mt-4 text-xs text-gray-300"
              >
              </span>
            <% else %>
              <span class="text-center mt-4 text-xs text-gray-300">
                Badge is ready to collect!
              </span>
            <% end %>
          </div>
        </div>

        <%= if !@collector and @badge.badge_redirect do %>
          <div class="w-full flex mt-4 justify-center">
            <a
              href={@badge.badge_redirect}
              replace={true}
              class="focus:outline-double text-gray-500 ml-2 my-auto p-1 h-fit ring-1 p-2 ring-gray-300 z-30 shadow-md shadow-highlight/[0.50] bg-gray-100 rounded-lg"
            >
              <span class="hero-link w-4 h-4"></span> Visit Link
            </a>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end
end
