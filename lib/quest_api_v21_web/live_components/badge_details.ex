defmodule QuestApiV21Web.LiveComponents.BadgeDetails do
  use Phoenix.LiveComponent

  def mount(assigns) do
    {:ok, assigns}
  end



  def render(assigns) do

    ~H"""
    <div
      id={@id}
      class={"animate__animated  inset-0 z-40 h-screen fixed w-full overflow-y-auto
      #{if @show, do: "animate__slideInUp animate__faster", else: "animate__slideOutDown" }"}
    >

        <div
          class={"#{if @show, do: "fade-in-scale", else: "hidden animate__slideOutDown"} animate__animated w-full h-screen bg-white text-left overflow-hidden shadow-xl transform transition-all"}
          role="dialog"
          aria-modal="true"
          tabindex="-1"
        >
        <div class="mx-auto w-10/12">
        <button type="button" class="mt-6" phx-click="cancel">
          <span class="hero-chevron-down"> </span>
        </button>

        <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <div class="sm:flex sm:items-start">
              <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-title">
                  <%= @badge.name %>
                </h3>
              </div>
            </div>
          </div>

          <div class="w-full border-2 border-slate-700 h-96 max-w-96 overflow-hidden relative rounded-lg">
            <%= if @badge.collected do %>
              <img src={@badge.badge_details_image} alt="Badge Image" class="object-cover w-full h-full">
            <% else %>
              <div class="h-96 bg-black flex justify-center">
                <h1 class="text-white my-auto text-lg"><%= @badge.hint %></h1>
              </div>
            <% end %>

            </div>
            <h1 class="mt-12"><%= @quest.name %></h1>
            <div class="h-1 bg-brand" style={"width:#{@comp_percent}%"} ></div>

            <div class="flex justify-center">
              <button phx-click="previous" class="border-2 m-2">
              <span class="hero-chevron-double-left"/>
            </button>

            <button phx-click="next" class="border-2 m-2">
              <span class="hero-chevron-double-right" />
            </button>
          </div>

          </div>
        </div>
    </div>
    """
  end
end
