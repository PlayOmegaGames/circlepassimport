defmodule QuestApiV21Web.LiveComponents.Camera do
  use Phoenix.LiveComponent

  def mount(assigns) do
    {:ok, assigns}
  end

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class={"animate__animated  inset-0 z-40 h-screen fixed w-full overflow-y-auto
      #{if @show, do: "animate__slideInDown animate__faster", else: "animate__slideOutDown" }"}
    >
      <div id="container" class={"#{if @show, do: "fade-in-scale", else: "hidden animate__slideOutDown"} animate__animated w-full h-screen bg-white text-left overflow-hidden shadow-xl transform transition-all"}>
      <button type="button" class="m-6" phx-click="close-camera">
        <span class="hero-chevron-down"> </span>
      </button>
      <video
          class="mx-auto w-10/12 rounded-lg h-10/12"
          id="videoElement"
          autoplay="true"
          playsInline="true"
          muted="true"
          phx-hook="QrScanner">
        >
        </video>
      </div>
    </div>
    """
  end

end
