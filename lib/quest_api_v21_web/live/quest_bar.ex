defmodule QuestApiV21Web.QuestBar do
  use QuestApiV21Web, :live_view
  alias QuestApiV21Web.LiveComponents.CompTest
  alias QuestApiV21.Accounts

  def mount(_session, params, socket) do
    user_id = params["user_id"]
    account = Accounts.get_account!(user_id)
    socket =
      socket
      |> assign(:account, account)
      |> assign(:socketid, socket.id)
      |> assign(show_comp_test: false)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="fixed bottom-1 border-2 border-gray-800">
      <h1>Quest Bar</h1>
      <p> User ID:  <%= assigns.account.name %> </p>
      <button phx-click="off" class="border-2 m-8">Off</button>
      <button phx-click="on" class="border-2 m-8">On</button>
    </div>

    <%= if @show_comp_test do %>
      <div class="fixed top-0 right-0 m-4">
        <%= live_component CompTest, id: :comp_test, name: "Emperor" %> <!-- Render CompTest with props -->
      </div>
    <% end %>
    """
  end

  def handle_event("on", _, socket) do
    {:noreply, assign(socket, show_comp_test: true, nane: :socketid)}
  end

  def handle_event("off", _, socket) do
    {:noreply, assign(socket, show_comp_test: false)}
  end
end
