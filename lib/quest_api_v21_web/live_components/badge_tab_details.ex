defmodule QuestApiV21Web.LiveComponents.BadgeTabDetails do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class={"animate__animated inset-0 h-screen fixed w-full overflow-y-auto z-50
      #{if @show, do: "animate__slideInUp animate__faster", else: "animate__slideOutDown"}"}
    >
    <button type="button"
            class={"absolute rounded-full bg-black/40 p-1 z-50 top-2 left-2 #{if @show, do: "fade-in-scale", else: "hidden"}"}
            phx-click="cancel">
      <span class="w-6 h-6 text-white hero-x-mark"></span>
    </button>
      <%= if @badge do %>
        <div
          class={"#{if @show, do: "fade-in-scale", else: "hidden animate__slideOutDown"}
                  bg-center bg-cover
                  animate__animated w-full h-screen text-left overflow-hidden shadow-xl transform transition-all"}
          style={"background-image: url(#{@badge.badge_details_image})"}
          role="dialog"
          aria-modal="true"
          tabindex="-1"
          phx-click={JS.toggle_class("hidden", to: "#ui-overlay-#{@id}")}>

          <div class=" bg-gradient-to-b from-black/30 via-black/30 to-black/90 h-screen" id={"ui-overlay-#{@id}"}>
            <div class="flex h-12 bg-gradient-to-b from-black/30">

            </div>

            <div class="absolute bottom-0 bg-gradient-to-t from-black/70 w-full">
              <div class="ml-6 text-white">

                <div class="flex mb-4">
                  <img class="rounded-full w-12 h-12 ring-1 ring-gray-300" src={@badge.badge_image} />
                  <p class="font-light font-medium font-2xl truncate w-full ml-4 my-auto"><%= @badge.name %></p>
                </div>

                <p class="font-light truncate text-sm my-4"><%= @badge.quest.name %></p>

                <%= if @badge.quest.reward do %>
                  <p class="font-medium truncate text-xs mb-6">
                    <span class="hero-trophy-solid w-4 h-4"></span>
                    <%= @badge.quest.reward %>
                  </p>
                <% end %>

                <%= if @badge.badge_redirect do %>
                  <a
                    href={@badge.badge_redirect}
                    replace={true}
                    class="text-gray-800 font-light p-1 h-fit ring-1 p-2 ring-gray-300 z-30 bg-white shadow-md rounded-lg"
                  >
                    <span class="hero-link w-4 h-4"></span> Visit Link
                  </a>
                <% end %>

              </div>
              <div class="h-8 w-full"></div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
