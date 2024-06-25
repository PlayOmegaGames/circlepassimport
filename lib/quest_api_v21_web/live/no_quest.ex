defmodule QuestApiV21Web.NoQuest do
  use Phoenix.LiveView
  require Logger

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :show_camera, false) |> assign(:camera_error, nil)}
  end

  def handle_event("camera-error", %{"message" => msg}, socket) do
    {:noreply, assign(socket, :camera_error, msg)}
  end


  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={QuestApiV21Web.LiveComponents.Camera}
        id="camera_modal"
        show={@show_camera}
        on_confirm={:confirm_action}
        on_cancel={:cancel_action}
        confirm="Proceed"
        camera_error={@camera_error}
        cancel="close-camera"
      />

      <div class="px-0.5 bg-white rounded-t-xl">
        <div
          phx-click="toggle_badge_details_modal"
          id="quest-bar-container"
          class="relative rounded-xl z-10 w-full bg-gradient-to-r from-gray-100 to-gray-100 ring-transparent border border-gray-400"
        >
          <div class="flex py-1 h-16">
          <div class="my-auto grow">
            <span class="animate__flash animate__animated animate__slower my-auto ml-4">

            Scan a Quest QR code to start

            </span>

            <span class="my-auto hero-arrow-long-right"></span>
            </div>

            <!-- Camera -->
            <div class="flex justify-between border-l-2 border-gray-200">
              <div class="my-auto  px-5 z-20">
                <button
                  phx-click="camera"
                  class="ring-1 p-1 ring-gray-400 z-30 shadow-md shadow-brand/60 bg-gray-100 rounded-lg"
                >
                  <img class="w-8 h-8 opacity-70" src="/images/qr-code.png" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("camera", _params, socket) do
    new_visibility = not socket.assigns.show_camera
    {:noreply, assign(socket, :show_camera, new_visibility)}
  end

  def handle_event("close-camera", _params, socket) do
    # Hide the camera component
    {:noreply, assign(socket, :show_camera, false)}
  end

  def handle_event("qr-code-scanned", %{"data" => qr_data}, socket) do
    # Ensure the QR data has a scheme, defaulting to https if not provided
    qr_data =
      if String.starts_with?(qr_data, ["http://", "https://"]) do
        qr_data
      else
        "https://" <> qr_data
      end

    uri = URI.parse(qr_data)
    allowed_domains = ["questapp.io", "staging.questapp.io"]

    cond do
      uri.host in allowed_domains ->
        # Construct the relative path only
        relative_path = uri.path <> ((uri.query != nil && "?#{uri.query}") || "")
        Logger.info("Redirecting to: #{relative_path}")
        socket = assign(socket, :show_qr_success, true)
        {:noreply, push_redirect(socket, to: relative_path)}

      true ->
        Logger.error("Invalid domain in scanned QR code: #{uri.host}")
        {:noreply, socket}
    end
  end
end
