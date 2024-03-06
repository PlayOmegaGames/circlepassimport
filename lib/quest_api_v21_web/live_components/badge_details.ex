defmodule QuestApiV21Web.LiveComponents.BadgeDetails do
  use Phoenix.LiveComponent

  def mount(assigns) do
    {:ok, assigns}
  end



  def render(assigns) do

    ~H"""
    <div
      id={@id}
      class={"inset-0 z-50 h-screen fixed w-full overflow-y-auto #{if @show, do: "fade-in", else: "hidden"}"}
    >
      <div class="flex items-end justify-center min-h-screen text-center sm:block sm:p-0">
        <div
          class={"#{if @show, do: "fade-in-scale", else: "hidden"} w-full h-screen bg-white text-left overflow-hidden shadow-xl transform transition-all w-full"}
          role="dialog"
          aria-modal="true"
          tabindex="-1"
        >
        <button type="button" class="mt-4 ml-4" phx-click="cancel">
        <span class="hero-chevron-down"> </span>
      </button>

        <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <div class="sm:flex sm:items-start">
              <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-title">
                  <%= @title %>
                </h3>
              </div>
            </div>
          </div>

            <img src={@badge.badge_details_image} />

            <div class="flex">
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
