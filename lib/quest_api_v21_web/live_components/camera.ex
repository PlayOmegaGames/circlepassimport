defmodule QuestApiV21Web.LiveComponents.Camera do
  use Phoenix.LiveComponent

  def mount(assigns) do
    {:ok, assigns}
  end

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class=
        {"animate__animated  inset-0 z-40 h-screen fixed w-full overflow-y-auto
      #{if @show, do: "animate__slideInDown animate__faster", else: "animate__slideOutDown" }"}>
      <div id="camera" class={"#{if @show, do: "fade-in-scale", else: "hidden animate__slideOutDown"}  animate__animated w-full h-screen bg-gradient-to-b from-white to-indigo-100 text-left overflow-hidden shadow-xl transform transition-all"}>


      <video
          class="mx-auto w-10/12 rounded-lg mt-12 ring-2 h-10/12 max-w- ring-gold-200"
          id="videoElement"
          autoplay="true"
          playsInline="true"
          muted="true"
          phx-hook="QrScanner">

        </video>
        <h1 class="mt-6 text-center">[ Scanning for a Quest QR code... ]</h1>

        <div class="flex justify-center w-full">
        <span class="mx-auto mt-2 w-6 h-6 text-gray-600 animate-spin hero-arrow-path"></span>
        </div>

        <button type="button" class="absolute bottom-16 w-full" phx-click="close-camera">
          <span class="w-12 h-12 text-center text-gray-500 hero-chevron-down"> </span>
        </button>

      </div>
    </div>
    """
  end
end
