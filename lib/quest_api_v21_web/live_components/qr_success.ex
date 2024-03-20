defmodule QuestApiV21Web.LiveComponents.QrSuccess do

  use Phoenix.LiveComponent

  def render(assigns) do

    ~H"""
    <div
      class=
        {"animate__animated w-full h-screen fixed bg-white/[0.90] transition-all ease-in-out top-0 text-lg font-medium text-center text-gray-800
      #{if @show, do: "", else: "hidden" }"}>
      <div class=" rounded-full border-2 w-fit m-auto mt-40 border-green-600">
          <span class="hero-check-circle text-gray-600 m-12 w-20 h-20"></span>
      </div>
    </div>
    """

  end
end
