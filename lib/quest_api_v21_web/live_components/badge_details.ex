defmodule QuestApiV21Web.LiveComponents.BadgeDetails do
  use Phoenix.LiveComponent

  def mount(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class={"animate__animated inset-0 h-screen fixed w-full overflow-y-auto z-40 #{if @show, do: "animate__slideInUp animate__faster", else: "animate__slideOutDown"}"}
    >
      <div
        class={"#{if @show, do: "fade-in-scale", else: "hidden animate__slideOutDown"} animate__animated w-full h-screen bg-accent text-left overflow-hidden shadow-xl transform transition-all"}
        role="dialog"
        aria-modal="true"
        tabindex="-1"
      >
        <%= if @badge.loyalty_badge do %>
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
                <%= if @coordinates.latitude && @coordinates.longitude do %>
                  <div
                    id="map"
                    phx-hook="LeafletMap"
                    class="w-full h-full"
                    data-latitude={@coordinates.latitude}
                    data-longitude={@coordinates.longitude}
                  ></div>
                <% else %>
                  <div class="flex justify-center h-96 bg-black">
                    <h1 class="my-auto text-lg text-white"><%= @badge.hint %></h1>
                  </div>
                <% end %>
              <% end %>
            </div>

            <div class="mt-6 mb-4 flex justify-between">
              <div>
                <h1 class="text-xs font-thin uppercase">Next Reward</h1>
                <h1 class="font-bold truncate"><%= @next_reward || "N/A" %></h1>
              </div>

              <div>
                <h1 class="text-xs font-thin uppercase text-right">Quest</h1>
                <h1 class="font-bold truncate"><%= @quest.name %></h1>
              </div>
            </div>

            <div class="flex justify-between mx-auto w-8/12">
              <button phx-click="previous" class="my-auto">
                <span class="w-12 h-12 hero-chevron-left" />
              </button>

              <div class="flex justify-center mx-auto w-8/12">
                <.live_component
                  module={QuestApiV21Web.LiveComponents.CameraButton}
                  id="camera-button"
                  size="12"
                />
              </div>

              <button phx-click="next" class="my-auto">
                <span class="w-12 h-12 hero-chevron-right" />
              </button>
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
                <span id="badge-ready" class="text-center mt-4 text-xs text-gray-300">
                  Badge is ready to collect!
                </span>
                <span
                  id="countdown-timer"
                  data-next-scan-date={@next_scan_date}
                  class="text-center mt-4 text-xs text-gray-300"
                >
                </span>
              </div>
            </div>
          </div>
        <% else %>
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
                <%= if @coordinates.latitude && @coordinates.longitude do %>
                  <div
                    id="map"
                    class="w-full h-full"
                    phx-hook="LeafletMap"
                    data-latitude={@coordinates.latitude}
                    data-longitude={@coordinates.longitude}
                  ></div>
                <% else %>
                  <div class="flex justify-center h-96 bg-black">
                    <h1 class="my-auto text-lg text-white"><%= @badge.hint %></h1>
                  </div>
                <% end %>
              <% end %>
            </div>

            <div class="mt-6 mb-4">
              <h1 class="text-xs font-thin uppercase">Quest Reward</h1>
              <h1 class="font-bold truncate"><%= @quest.reward %></h1>
            </div>

            <div class="rounded-full mb-2 bg-indigo-300/[0.30]">
              <div style={"width: #{@comp_percent}%;"} class="z-10 h-1 rounded-full bg-gold-300">
              </div>
            </div>

            <h1 class="mb-2 text-center"><%= @quest.name %></h1>

            <div class="flex justify-between mx-auto w-8/12">
              <button phx-click="previous" class="my-auto">
                <span class="w-12 h-12 hero-chevron-left" />
              </button>

              <.live_component
                module={QuestApiV21Web.LiveComponents.CameraButton}
                id="camera-button"
                size="12"
              />

              <button phx-click="next" class="my-auto">
                <span class="w-12 h-12 hero-chevron-right" />
              </button>
            </div>
          </div>
        <% end %>
      </div>

      <script>

        document.addEventListener("DOMContentLoaded", function() {
          const startCountdown = (endTime, countdownElement, badgeReadyElement) => {
            let countdownInterval;

            const updateCountdown = () => {
              const now = new Date().getTime();
              const distance = endTime - now;

              if (distance < 0) {
                clearInterval(countdownInterval);
                countdownElement.innerHTML = "";
                badgeReadyElement.classList.remove("hidden");
              } else {
                badgeReadyElement.classList.add("hidden");
                const days = Math.floor(distance / (1000 * 60 * 60 * 24));
                const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((distance % (1000 * 60)) / 1000);

                let display = "";
                if (days > 0) display += `${days}d `;
                if (hours > 0 || days > 0) display += `${hours}h `;
                if (minutes > 0 || hours > 0 || days > 0) display += `${minutes}m `;
                if (seconds > 0 || minutes > 0 || hours > 0 || days > 0) display += `${seconds}s `;

                countdownElement.innerHTML = display;
              }
            };

            countdownInterval = setInterval(updateCountdown, 1000);
            updateCountdown();
          };

          const countdownElement = document.getElementById("countdown-timer");
          const badgeReadyElement = document.getElementById("badge-ready");
          if (countdownElement && badgeReadyElement) {
            const nextScanDate = new Date(countdownElement.dataset.nextScanDate);
            startCountdown(nextScanDate.getTime(), countdownElement, badgeReadyElement);
          }

          const mapElement = document.getElementById("map");
          if (mapElement) {
            const latitude = parseFloat(mapElement.dataset.latitude) || 0;
            const longitude = parseFloat(mapElement.dataset.longitude) || 0;

            console.log("Initializing map with coordinates:", latitude, longitude); // Debugging line

            const map = L.map(mapElement).setView([latitude, longitude], 13);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
              attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(map);

            const purpleIcon = L.divIcon({
              className: 'custom-div-icon',
              html: "<div style='background-color: purple; width: 12px; height: 12px; border-radius: 50%;'></div>",
              iconSize: [12, 12],
              iconAnchor: [6, 6]
            });

            L.marker([latitude, longitude], { icon: purpleIcon }).addTo(map);
          }
        });
      </script>
    </div>
    """
  end
end
