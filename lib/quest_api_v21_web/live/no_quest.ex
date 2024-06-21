defmodule QuestApiV21Web.NoQuest do
  use Phoenix.LiveView
  require Logger

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :show_camera, false)}
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
        ,
        cancel="close-camera"
      />

      <div class="z-10 z-50 w-full bg-gradient-to-r from-gray-300 to-violet-100 border-t-2 border-contrast">
        <div class="my-auto mr-4 py-1 flex justify-between w-full">
          <span class="animate__flash animate__animated animate__slower my-auto ml-4">
            Scan a Quest QR code to start
          </span>
          <span class="my-auto hero-arrow-long-right"></span>
          <!--<button
            phx-click="camera"
            class="ring-1 p-1 mr-2 ring-gray-300 shadow-sm shadow-highlight/[0.60] bg-gray-100 rounded-lg"
          >
            <span class="hero-qr-code w-8 h-8"></span>
          </button>-->
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
