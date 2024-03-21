defmodule QuestApiV21Web.LiveComponents.BadgeDetails do
  use Phoenix.LiveComponent

  def mount(assigns) do

    {:ok, assigns}
  end



  def render(assigns) do

    ~H"""
    <div
      id={@id}
      class={"animate__animated  inset-0 h-screen fixed w-full overflow-y-auto z-40
      #{if @show, do: "animate__slideInUp animate__faster ", else: "animate__slideOutDown" }"}>

        <div
          class={"#{if @show, do: "fade-in-scale", else: "hidden animate__slideOutDown"}  animate__animated w-full h-screen bg-accent text-left overflow-hidden shadow-xl transform transition-all"}
          role="dialog"
          aria-modal="true"
          tabindex="-1"
        >


        <div class="mx-auto w-10/12 text-white">
          <div class="flex py-6">
            <button type="button" class="" phx-click="cancel">
              <span class="w-6 h-6 hero-chevron-down"> </span>
            </button>
            <h3 class="overflow-hidden mr-8 w-full text-lg font-medium text-center uppercase truncate" id="modal-title">
              <%= @badge.name %>
            </h3>
            </div>


          <div class="overflow-hidden relative mx-auto w-80 h-96 rounded-lg ring-1 ring-gold-200 object-fit">
            <%= if @badge.collected do %>
              <img src={@badge.badge_details_image} alt="Badge Image" class="object-cover w-full h-full">
            <% else %>
              <div class="flex justify-center h-96 bg-black">
                <h1 class="my-auto text-lg text-white"><%= @badge.hint %></h1>
              </div>
            <% end %>
          </div>

          <div class="mt-6 mb-4">
            <h1 class="text-xs font-thin uppercase">Quest Reward</h1>
            <h1 class="font-bold truncate"><%= @quest.reward %></h1>
          </div>

          <div class="rounded-full mb-2 bg-indigo-300/[0.30]">
            <div style={"width: #{@comp_percent}%;"} class="z-10 h-1 rounded-full bg-gold-300"></div>
          </div>

          <h1 class="mb-2 text-center"><%= @quest.name %></h1>

          <div class="flex justify-between mx-auto w-8/12">
            <button phx-click="previous" class="my-auto">
              <span class="w-12 h-12 hero-chevron-left"/>
            </button>

            <.live_component module={QuestApiV21Web.LiveComponents.CameraButton} id="camera-button" size="12" />

            <button phx-click="next" class="my-auto">
              <span class="w-12 h-12 hero-chevron-right" />
            </button>
          </div>


          </div>
        </div>
    </div>
    """
  end
end
