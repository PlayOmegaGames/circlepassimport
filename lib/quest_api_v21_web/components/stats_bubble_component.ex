defmodule QuestApiV21Web.StatsBubbleComponent do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import QuestApiV21Web.Gettext

  @doc """
    the stat bubbles
  """
  attr :text, :string, required: true
  attr :color, :string, required: true
  attr :number, :string, required: true


  def stats_bubble(assigns) do
    ~H"""
    <div class="">
      <div class={"mx-auto bg-#{@color}-200 border-2 shadow-lg border-#{@color}-500 flex justify-center items-center rounded-full h-14 w-14"}>
          <p class="text-slate-700 font-semibold">
            <%= @number %>
          </p>
      </div>

      <p class="text-center mt-2 text-sm font-light text-slate-700">
      <%= @text %>
      </p>
    </div>
    """
  end

end
