defmodule QuestApiV21Web.LiveComponents.Camera do
  use Phoenix.LiveComponent

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Assign default values including camera_error
      socket = assign(socket, :camera_error, nil)
      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class={"animate__animated inset-0 z-50 fixed w-full h-full overflow-hidden
      #{if @show, do: "animate__slideInDown animate__faster", else: "hidden"}
      bg-black"}
    >
      <video
        id="videoElement"
        autoplay="true"
        playsInline="true"
        muted="true"
        phx-hook="QrScanner"
        style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover;"
      >
      </video>
      <h1 class="text-white text-center absolute w-full bottom-32">
        <%= if @camera_error do %>
          <%= @camera_error %>
        <% else %>
          [ Scanning for a Quest QR code... ]
        <% end %>
      </h1>

      <div class="flex justify-center w-full absolute bottom-16">
        <button
          type="button"
          class="text-white text-lg bg-brand font-semibold py-2 px-4 rounded"
          phx-click="close-camera"
        >
          Close Camera
        </button>
      </div>
    </div>
    """
  end

  def handle_event("camera-error", %{"message" => msg}, socket) do
    {:noreply, assign(socket, :camera_error, msg)}
  end
end
