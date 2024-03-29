

defmodule QuestApiV21Web.LiveComponents.BadgeTabDetails do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""

    <div
      id={@id}
      class={"animate__animated  inset-0 h-screen fixed w-full overflow-y-auto z-50
      #{if @show, do: "animate__slideInUp animate__faster ", else: "animate__slideOutDown" }"}>
      <%= if @badge do %>


        <div
          class={"#{if @show, do: "fade-in-scale", else: "hidden animate__slideOutDown"}  animate__animated w-full h-screen bg-accent text-left overflow-hidden shadow-xl transform transition-all"}
          role="dialog"
          aria-modal="true"
          tabindex="-1"
        >
        <button type="button" class="" phx-click="cancel">
          <span class="w-6 h-6 mt-4 ml-4 text-white hero-x-mark"> </span>
        </button>
        <.live_component module={QuestApiV21Web.BadgeDisplayComponent} id={"single-badge-#{@id}"}
        badge={@badge} quest={nil} error={nil} collector={nil}/>


        </div>
        <% end %>

        </div>
    """
  end
end
