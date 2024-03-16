defmodule QuestApiV21Web.CameraLive do
  use Phoenix.LiveView
  require Logger

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :show_camera, false)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.live_component module={QuestApiV21Web.LiveComponents.Camera}
        id = "camera_modal"
        show =  {@show_camera}
        on_confirm = {:confirm_action}
        on_cancel = {:cancel_action}
        confirm = "Proceed",
        cancel = "close-camera" />

      <div class="fixed bottom-14 z-10 w-full bg-white border-t border-gray-800 -2">
        <button phx-click="camera" class="m-2 w-10 h-10 text-white rounded-full border-2 bg-brand">
          <span class="w-6 h-6 hero-qr-code" />
        </button>
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
    [domain | rest_of_path] = String.split(qr_data, "/", parts: 2)
    actual_path = Enum.join(rest_of_path, "/")

    cond do
      domain in ["questapp.io", "4000-circlepassio-questapiv2-nqb4a6c031c.ws-us108.gitpod.io", "staging.questapp.io"] ->
        full_path = "/" <> actual_path
        Logger.info("Redirecting to: #{full_path}")
        {:noreply, push_redirect(socket, to: full_path)}
      true ->
        Logger.error("Invalid domain in scanned QR code: #{domain}")
        {:noreply, socket}
    end
  end

  # Implement additional handlers for :confirm_action and :cancel_action if needed.
end
