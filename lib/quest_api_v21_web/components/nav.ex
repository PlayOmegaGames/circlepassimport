defmodule QuestApiV21Web.Nav do
  use Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    active_tab =
      case socket.view do
        QuestApiV21Web.HomeLive -> :home
        QuestApiV21Web.QuestsLive -> :quests
        QuestApiV21Web.ProfileLive -> :profile
        _ -> :none
      end

    {:cont, assign(socket, :active_tab, active_tab)}
  end
end
