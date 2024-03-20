defmodule QuestApiV21Web.LiveComponents.CollectorBar do
  use Phoenix.LiveComponent

  def render(assigns) do

    ~H"""

    <div class="bottom-14 w-full fixed z-10 w-full bg-gradient-to-r from-gray-300 to-violet-100 border-t-2 border-contrast">

    <div class="py-2 flex justify-center w-full">

    <div class="relative w-fit py-2">

        <.link patch={"/home"} replace={true} class="focus:outline-double text-gray-500  my-auto p-1 h-fit ring-1 p-2 ring-gray-300 z-30 shadow-md shadow-highlight/[0.50] bg-gray-100 rounded-lg">
          <span class="hero-check-circle w-5 h-5"></span> Collect Badge
        </.link>
        <span class="absolute -right-1 -top-1 flex h-3 w-3">
          <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-highlight opacity-75"></span>
          <span class="relative inline-flex rounded-full h-3 w-3 bg-highlight"></span>
        </span>

      </div>
    </div>

    </div>

    """

  end


end
