defmodule QuestApiV21Web.ShellLive do
  use QuestApiV21Web, :live_view

  def mount(_session, _params, socket) do
    # Set a default value for @inner_content
    # You can adjust this to load initial content as needed
    socket = assign(socket, :inner_content, "")

    # IO.inspect(socket)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="text-4xl">
      Test
      <main>
        <%= @inner_content %>
      </main>
    </div>
    """
  end

  def handle_info(:update_content, socket) do
    # Logic to change @inner_content based on the application's state or a passed message
    {:noreply, socket}
  end
end
