defmodule QuestApiV21Web.Nav do
  use Phoenix.LiveView

  def on_mount(:default, params, _session, socket) do
    active_tab = determine_active_tab(params, socket)
    #IO.inspect(socket.assigns)
    {:cont, assign(socket, :collector, false)}
  end

  defp determine_active_tab(params, socket) do
    # Assuming you're passing the current path as a param to LiveView
    # Adjust this logic based on how you differentiate your routes in MainLive
    case socket.assigns[:live_action] || params["tab"] do
      :home -> :home  # or check for specific tabs if needed, e.g., params["tab"] == "badges"
      :quests -> :quests
      :profile -> :profile
      _ -> :none
    end
  end



end
