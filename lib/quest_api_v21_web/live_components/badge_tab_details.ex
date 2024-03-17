defmodule QuestApiV21Web.LiveComponents.BadgeTabDetails do
  use Phoenix.LiveComponent

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
              <img src={@badge.badge_details_image} alt="Badge Image" class="object-cover w-full h-full"/>
          </div>

          <div class="flex justify-between mx-auto w-8/12">


          </div>


          </div>
        </div>
    </div>
    """
  end
end
