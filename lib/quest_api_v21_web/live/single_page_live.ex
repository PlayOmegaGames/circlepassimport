defmodule QuestApiV21Web.SinglePageLive do
  use QuestApiV21Web, :live_view


  def mount(_params, _session, socket) do
    socket = assign(socket, page: "home")


    {:ok, socket}
  end


  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <!-- page content -->
      <%= @page %>
    <!-- Bottom Nav -->
      <div class="frosted-glass fixed w-full bottom-0 h-16 border-t-2 border-slate-300">
        <div class="grid grid-cols-3 justify-items-center text-slate-700">
          <div>
          <!--Find a better way of using Hero Icons -->
            <button phx-click="home">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
              <path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25" />
              </svg>
              <p class=" text-center">Home</p>
            </button>
          </div>
          <div>
            <button phx-click="available quests">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
              <path stroke-linecap="round" stroke-linejoin="round" d="m6.115 5.19.319 1.913A6 6 0 0 0 8.11 10.36L9.75 12l-.387.775c-.217.433-.132.956.21 1.298l1.348 1.348c.21.21.329.497.329.795v1.089c0 .426.24.815.622 1.006l.153.076c.433.217.956.132 1.298-.21l.723-.723a8.7 8.7 0 0 0 2.288-4.042 1.087 1.087 0 0 0-.358-1.099l-1.33-1.108c-.251-.21-.582-.299-.905-.245l-1.17.195a1.125 1.125 0 0 1-.98-.314l-.295-.295a1.125 1.125 0 0 1 0-1.591l.13-.132a1.125 1.125 0 0 1 1.3-.21l.603.302a.809.809 0 0 0 1.086-1.086L14.25 7.5l1.256-.837a4.5 4.5 0 0 0 1.528-1.732l.146-.292M6.115 5.19A9 9 0 1 0 17.18 4.64M6.115 5.19A8.965 8.965 0 0 1 12 3c1.929 0 3.716.607 5.18 1.64" />
              </svg>
              <p class=" text-center">Available Quests</p>
            </button>
          </div>
          <div>
            <button phx-click="profile">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
              </svg>
              <p class=" text-center">Profile</p>
            </button>
          </div>
        </div>
    </div>

    """
  end

  def handle_event("home", _, socket) do
    socket = assign(socket, page: "home")
    {:noreply, socket}
  end
  def handle_event("available quests", _, socket) do
    socket = assign(socket, page: "new")
    {:noreply, socket}
  end
  def handle_event("profile", _, socket) do
    socket = assign(socket, page: "profile")
    {:noreply, socket}
  end
end
