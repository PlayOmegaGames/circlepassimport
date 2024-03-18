defmodule QuestApiV21Web.LiveComponents.CameraButton do
  use Phoenix.LiveComponent

  def render(assigns) do

    ~H"""

      <button
      phx-click="camera"
      class={"flex justify-center w-#{@size} h-#{@size} rounded-full ring-2 shadow-md ring-gold-300 shadow-white/[0.70] bg-contrast"}>
      <span class="m-1 w-full h-full text-gray-800 hero-qr-code"/>
      </button>

    """

  end

end
