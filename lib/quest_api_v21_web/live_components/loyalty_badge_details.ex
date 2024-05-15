defmodule QuestApiV21Web.LiveComponents.LoyaltyBadgeDetails do
  use Phoenix.LiveComponent
  alias QuestApiV21.GordianKnot
  alias QuestApiV21.Repo

  def mount(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def update(assigns, socket) do
    badge = assigns[:badge] |> Repo.preload(:quest)
    account_id = assigns[:account_id]

    total_transactions = GordianKnot.count_transactions_for_badge(account_id, badge.id)
    total_points = GordianKnot.count_points_for_badge(account_id, badge.id)
    next_scan_date = GordianKnot.get_next_scan_date(account_id, badge)

    case GordianKnot.get_next_reward(account_id, badge.id, badge.quest) do
      {:ok, nil} ->
        {:ok,
         socket
         |> assign(assigns)
         |> assign(:badge, badge)
         |> assign(:total_transactions, total_transactions)
         |> assign(:total_points, total_points)
         |> assign(:next_reward, nil)
         |> assign(:next_scan_date, next_scan_date)}

      {:ok, {_next_reward_points, next_reward}} ->
        {:ok,
         socket
         |> assign(assigns)
         |> assign(:badge, badge)
         |> assign(:total_transactions, total_transactions)
         |> assign(:total_points, total_points)
         |> assign(:next_reward, next_reward)
         |> assign(:next_scan_date, next_scan_date)}
    end
  end

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class={"animate__animated  inset-0 h-screen fixed w-full overflow-y-auto z-40
      #{if @show, do: "animate__slideInUp animate__faster ", else: "animate__slideOutDown" }"}
    >
      <div
        class={"#{if @show, do: "fade-in-scale", else: "hidden animate__slideOutDown"}  animate__animated w-full h-screen bg-accent text-left overflow-hidden shadow-xl transform transition-all"}
        role="dialog"
        aria-modal="true"
        tabindex="-1"
      >
        <div class="mx-auto w-10/12 text-white">
          <div class="flex py-6">
            <button type="button" class="" phx-click="cancel">
              <span class="w-6 h-6 hero-chevron-down"></span>
            </button>
            <h3
              class="overflow-hidden mr-8 w-full text-lg font-medium text-center uppercase truncate"
              id="modal-title"
            >
              <%= @badge.name %>
            </h3>
          </div>

          <div class="overflow-hidden relative mx-auto w-72 h-80 rounded-lg ring-1 ring-gold-200 object-fit">
            <%= if @badge.collected do %>
              <img
                src={@badge.badge_details_image}
                alt="Badge Image"
                class="object-cover w-full h-full"
              />
            <% else %>
              <div class="flex justify-center h-96 bg-black">
                <h1 class="my-auto text-lg text-white"><%= @badge.hint %></h1>
              </div>
            <% end %>
          </div>

          <div class="mt-6 mb-4 flex justify-between">
            <div>
              <h1 class="text-xs font-thin uppercase">Next Reward</h1>
              <h1 class="font-bold truncate"><%= @next_reward %></h1>
            </div>

            <div>
              <h1 class="text-xs font-thin uppercase text-right">Quest</h1>
              <h1 class="font-bold truncate"><%= @quest.name %></h1>
            </div>
          </div>

          <div class="flex justify-center mx-auto w-8/12">
            <.live_component
              module={QuestApiV21Web.LiveComponents.CameraButton}
              id="camera-button"
              size="12"
            />
          </div>
          <!-- Display Next Reward, Total Transactions, and Next Scan Date -->
          <div class="mt-4 text-center text-sm">
            <h1 class="">You have collected this badge <%= @total_transactions %> times</h1>
            <h1 class="text-light text-gold-100 mt-2 text-center ml-1">
              You have a total of <span class="font-bold"><%= @total_points %></span> points
            </h1>
          </div>

          <div class="flex justify-center mb-4">
            <div class="h-4 w-fit">
              <span class="hero-clock h-4 w-4"></span>
              <span
                id="countdown-timer"
                data-next-scan-date={@next_scan_date}
                phx-hook="CountdownTimer"
                class="text-center mt-4 text-xs text-gray-300"
              >
              </span>
              <!-- Countdown Timer Placeholder -->
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
