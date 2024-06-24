defmodule QuestApiV21Web.LiveComponents.QuestDetails do
  use Phoenix.LiveComponent

  def mount(assigns) do
    {:ok, assigns}
  end

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class={"animate__animated  inset-0 h-screen fixed w-full overflow-y-auto z-50
      #{if @show, do: "animate__slideInUp animate__faster ", else: "animate__slideOutDown" }"}
    >
      <div
        class={"#{if @show, do: "fade-in-scale", else: "hidden animate__slideOutDown"}  animate__animated w-full bg-white h-screen text-left shadow-xl overflow-y-auto transform transition-all"}
        role="dialog"
        aria-modal="true"
        tabindex="-1"
      >
        <div class="px-8 text-gray-700 pt-4">
          <button type="button" class="" phx-click="quest_details_cancel">
            <span class="w-6 h-6 hero-chevron-down"></span>
          </button>
          <h3 class="overflow-hidden mr-8 w-full text-2xl font-medium text-center" id="modal-title">
            <%= @quest_details.name %>
          </h3>
          <h4 class="px-8 mt-6 mb-4 w-full text-center text-brand ">
            <%= @quest_details.reward %>
          </h4>
          <p class="text-gray-500 border-t border-gray-300 pt-2">
          <%= if @quest_details do %>
            <%= @quest_details.description %>
          <% end %>
          </p>

          <div class="mt-4">
          <h5 class="text-lg font-semibold">Your Progress</h5>
          <div class="flow-root">
            <ul role="list" class="py-5">
              <%= for badge <- @quest_details.badges do %>
              <li>
                <div class="relative pb-8">
                  <!--Vertical line-->
                  <span class="absolute left-6 top-4 -ml-px h-full w-0.5 bg-gray-200" aria-hidden="true"></span>
                  <div class="relative flex space-x-3">
                    <div>
                      <span class={"flex h-12 w-12 items-center justify-center"}>
                      <img src={badge.badge_image} alt="Badge" class={"w-12 h-12 bg-cover rounded-full border-2 borer-white ring-2 #{if badge.collected, do: "ring-brand grayscale-0", else: "opacity-70 grayscale ring-gray-200"}"}/>
                      </span>
                    </div>
                    <div class="flex min-w-0 flex-1 justify-between space-x-4 pt-1.5">
                      <div>
                          <p class="text-gray-900"><%= badge.name %></p>
                          <p class="text-xs text-gray-500">
                            <%= if badge.collected, do: "Collected", else: "Not Collected" %>
                          </p>

                          </div>
                    </div>
                  </div>
                </div>
              </li>
              <% end %>
            </ul>
          </div>
        </div>


        </div>
      </div>
    </div>
    """
  end
end
