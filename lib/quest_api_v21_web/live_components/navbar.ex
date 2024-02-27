defmodule QuestApiV21Web.LiveComponents.Navbar do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""

      <!-- Bottom Nav -->
        <div class="frosted-glass fixed w-full bottom-0 h-16 border-t-2 border-slate-300">
        <div class="grid grid-cols-3 justify-items-center text-slate-700">
          <a
            href="/badges"
            class={"text-xs py-2 w-14 h-14  #{calculate_class(@conn.request_path, "/badges")}"}
          >
            <div>
              <!-- Replace with the appropriate icon HTML -->
              <span class={"ml-4 w-6 h-6 hero-home#{calculate_icon(@conn.request_path, "/badges")} "}>
              </span>
              <p class=" text-center">Home</p>
          </div>
          </a>

          <a
          href="/new"
          class={"text-xs py-2 w-14 h-14 #{calculate_class(@conn.request_path, "/new")}"}
        >
          <div>
            <!-- Replace with the appropriate icon HTML -->
              <span class={"ml-4 w-6 h-6 hero-globe-americas#{calculate_icon(@conn.request_path, "/new")}"}>
              </span>
              <p class="text-center">New</p>
          </div>
        </a>

          <a
            href="/profile"
            class={"text-xs py-2 w-14 h-14 #{calculate_class(@conn.request_path, "/profile")}"}
        >
            <div>
              <!-- Replace with the appropriate icon HTML -->
              <span class={"ml-4 w-6 h-6 hero-user#{calculate_icon(@conn.request_path, "/profile")}"}>
              </span>
            <p class="text-center">Profile</p>
            </div>
          </a>
      </div>
      </div>

    """
  end
end
