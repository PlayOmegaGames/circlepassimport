defmodule QuestApiV21Web.LiveComponents.Navbar do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <!-- Bottom Nav -->
    <div class="fixed bottom-0 w-full h-16 border-t-2 frosted-glass border-slate-300">
      <div class="grid grid-cols-3 justify-items-center text-slate-700">
        <a
          href="/badges"
          class={"text-xs py-2 w-14 h-14  #{QuestApiV21Web.Layouts.calculate_class(@conn.request_path, "/badges")}"}
        >
          <div>
            <!-- Replace with the appropriate icon HTML -->
            <span class={"ml-4 w-6 h-6 hero-home#{QuestApiV21Web.Layouts.calculate_icon(@conn.request_path, "/badges")} "}>
            </span>
            <p class="text-center">Home</p>
          </div>
        </a>

        <a
          href="/new"
          class={"text-xs py-2 w-14 h-14 #{QuestApiV21Web.Layouts.calculate_class(@conn.request_path, "/new")}"}
        >
          <div>
            <!-- Replace with the appropriate icon HTML -->
            <span class={"ml-4 w-6 h-6 hero-globe-americas#{QuestApiV21Web.Layouts.calculate_icon(@conn.request_path, "/new")}"}>
            </span>
            <p class="text-center">New</p>
          </div>
        </a>

        <a
          href="/profile"
          class={"text-xs py-2 w-14 h-14 #{QuestApiV21Web.Layouts.calculate_class(@conn.request_path, "/profile")}"}
        >
          <div>
            <!-- Replace with the appropriate icon HTML -->
            <span class={"ml-4 w-6 h-6 hero-user#{QuestApiV21Web.Layouts.calculate_icon(@conn.request_path, "/profile")}"}>
            </span>
            <p class="text-center">Profile</p>
          </div>
        </a>
      </div>
    </div>
    """
  end
end
