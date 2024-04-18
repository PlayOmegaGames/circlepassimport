defmodule QuestApiV21Web.LiveComponents.QuestDetails do
  use Phoenix.LiveComponent

  def mount(assigns) do
    {:ok, assigns}
  end

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class={"animate__animated  inset-0 h-screen fixed w-full overflow-y-auto z-50
      #{if @show, do: "animate__slideInUp animate__faster ", else: "animate__slideOutDown" }"}
    >
      <div
        class={"#{if @show, do: "fade-in-scale", else: "hidden animate__slideOutDown"}  animate__animated w-full h-screen bg-accent text-left overflow-hidden shadow-xl transform transition-all"}
        role="dialog"
        aria-modal="true"
        tabindex="-1"
      >
        <div class="mx-auto w-10/12 text-white mt-4">
          <button type="button" class="" phx-click="quest_details_cancel">
            <span class="w-6 h-6 hero-chevron-down"></span>
          </button>
          <h3 class="overflow-hidden mr-8 w-full text-2xl font-medium text-center" id="modal-title">
            <%= @quest_details.name %>
          </h3>
          <p class="mt-2 text-gold-200 text-center">
            Quest Size: <%= length(@quest_details.badges) %> badges
          </p>

          <h4 class="px-8 mt-6 mb-4 w-full text-center uppercase rounded-full bg-highlight">
            <%= @quest_details.reward %>
          </h4>
          <p class="text-gray-200">
            <%= @quest_details.description %>
          </p>
        </div>
      </div>
    </div>
    """
  end
end
