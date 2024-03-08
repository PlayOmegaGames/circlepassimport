defmodule QuestApiV21Web.LiveComponents.Badge do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div>
      <div
      class="badge-container bg-white rounded-full cursor-pointer"
      data-badge-details-image={@img}
      data-is-user-badge="true">
        <!-- Badge image and name -->
        <img
        src={@img}
        class="rounded-full ring-2">
        <p class="text-center mt-2 text-xs text-slate-700"><%= @name %></p>
      </div>
    </div>
    """
  end

  def live_render(assigns, _context) do
    render(assigns)
  end

end
