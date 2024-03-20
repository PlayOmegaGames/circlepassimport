defmodule QuestApiV21Web.CollectorLive do
  use Phoenix.LiveView
  alias QuestApiV21.Collectors
  alias QuestApiV21.Repo
  require Logger


  def handle_params(_unsigned_params, uri, socket) do
    pattern = ~r/badge\/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})/

    case Regex.run(pattern, uri) do
      [_, uuid] ->
        with {:ok, collector} <- fetch_collector(uuid),
             {:ok, account} <- fetch_account(socket.assigns.account),
             {:ok, badge} <- fetch_last_badge(collector.badges) do

          quest = badge.quest
          quest_badges = Repo.preload(quest, :badges) |> Map.get(:badges)
          total_badges_in_quest = length(quest_badges)

          case QuestApiV21.Accounts.add_badge_to_account(account.id, badge.id) do
            {:ok, "Badge already associated with the account"} ->
              Logger.info("Badge was already collected")
              # Refetch account to update badges list
              {:ok, updated_account} = fetch_account(account.id)
              shared_badges_count = count_shared_badges(updated_account.badges, quest_badges)
              badges_left = total_badges_in_quest - shared_badges_count
              {:noreply, assign(socket, :badge, badge)
               |> assign(:quest, badge.quest)
               |> assign(:badges_left, badges_left)
               |> assign(:total_badges_in_quest, total_badges_in_quest)}

            {:ok, _account} ->
              Logger.info("Badge added to account successfully.")
              # Refetch account to update badges list
              {:ok, updated_account} = fetch_account(account.id)
              shared_badges_count = count_shared_badges(updated_account.badges, quest_badges)
              badges_left = total_badges_in_quest - shared_badges_count
              {:noreply, assign(socket, :badge, badge)
               |> assign(:quest, badge.quest)
               |> assign(:badges_left, badges_left)
               |> assign(:total_badges_in_quest, total_badges_in_quest)}

            {:error, reason} ->
              log_error("Failed to add badge to account: #{reason}")
              {:noreply, assign(socket, :error, true)}
          end
        else
          {:error, msg} ->
            log_error(msg)
            {:noreply, assign(socket, :error, true)}
        end
      _ ->
        log_error("Invalid UUID format or no match found.")
        {:noreply, assign(socket, :error, true)}
    end
  end


  defp count_shared_badges(account_badges, quest_badges) do
    account_badge_ids = Enum.map(account_badges, & &1.id)
    quest_badge_ids = Enum.map(quest_badges, & &1.id)

    shared_badges = Enum.filter(account_badge_ids, fn badge_id ->
      badge_id in quest_badge_ids
    end)

    length(shared_badges)

  end



  defp fetch_collector(uuid) do
    case Collectors.get_collector(uuid) |> Repo.preload([:quests, :badges]) do
      nil -> {:error, "Collector not found."}
      collector -> {:ok, collector}
    end
  end

  defp fetch_account(account_id) do
    case Repo.get(QuestApiV21.Accounts.Account, account_id) do
      nil -> {:error, "Account not found."}
      account -> {:ok, Repo.preload(account, :badges)}
    end
  end

  defp fetch_last_badge(badges) do
    case Enum.at(badges, -1) do
      nil -> {:error, "Collector has no badges."}
      badge ->
        badge = Repo.preload(badge, :quest)
        {:ok, badge}
    end
  end

  defp log_error(msg) do
    Logger.error(msg)
  end

  def mount(_params, _session, socket) do
    current_account = socket.assigns.current_account.id

    socket =
      socket
      |> assign(error: false)
      |> assign(:background_color, "bg-background-800")
      |> assign(account: current_account)
      |> assign(qr_loading: false)

    {:ok, socket}
  end



  def render(assigns) do

  ~H"""
    <div>
      <.live_component module={QuestApiV21Web.BadgeDisplayComponent} id="collected-badge-details"
          badge={@badge} quest={@quest} error={@error} />
      <%= unless @error do %>
        <p class="text-gold-100 mt-2 text-center"><%= @badges_left %> more left in the quest!</p>
      <% end %>
    </div>
  """
  end

end
