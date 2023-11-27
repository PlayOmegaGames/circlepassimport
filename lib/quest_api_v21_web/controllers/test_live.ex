defmodule QuestApiV21Web.TestLive do
  use Phoenix.LiveView
  require Logger

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <button phx-click="emit_event">Emit Event</button>
    </div>
    <script type="text/javascript">
      document.addEventListener('DOMContentLoaded', function () {
        window.addEventListener("phx:test_event", function(event) {
          console.log("Received test event:", event.detail);
        });
      });
    </script>
    """
  end

  @impl true
  def handle_event("emit_event", _params, socket) do
    Logger.debug("About to push test_event")
    push_event(socket, "test_event", %{message: "Test event pushed"})
    Logger.debug("test_event pushed")
    {:noreply, assign(socket, :some_data, "Data to send back to client")}
  end

end
