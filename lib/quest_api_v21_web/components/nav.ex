defmodule QuestApiV21Web.Nav do
  use Phoenix.LiveView
  def on_mount(:default, _params, _session, socket) do
    #active_tab = determine_active_tab(params, socket)
    #IO.inspect(socket.assigns)
    {:cont, assign(socket, :collector, false)}
  end
end
