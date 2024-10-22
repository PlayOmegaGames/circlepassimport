defmodule QuestApiV21Web.CollectorLive do
  use Phoenix.LiveView
  alias QuestApiV21.Collectors
  alias QuestApiV21.Repo
  require Logger

  def handle_params(_unsigned_params, uri, socket) do
    pattern =
      ~r/badge\/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})/

    case Regex.run(pattern, uri) do
      [_, uuid] ->
        with {:ok, collector} <- fetch_collector(uuid),
             {:ok, account} <- fetch_account(socket.assigns.account),
             {:ok, badge} <- fetch_last_badge(collector.badges) do
          quest = badge.quest
          quest_badges = Repo.preload(quest, :badges) |> Map.get(:badges)
          total_badges_in_quest = length(quest_badges)
          live = quest.live

          handle_add_badge_result(
            QuestApiV21.GordianKnot.add_badge_to_account(account.id, badge.id),
            account.id,
            badge,
            quest,
            quest_badges,
            total_badges_in_quest,
            live,
            socket
          )
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

  defp handle_add_badge_result(
         {:ok, "Badge already associated with the account"},
         account_id,
         badge,
         quest,
         quest_badges,
         total_badges_in_quest,
         live,
         socket
       ) do
    Logger.info("Badge was already collected")

    update_account_and_assign_badges(
      account_id,
      badge,
      quest,
      quest_badges,
      total_badges_in_quest,
      live,
      socket
    )
  end

  defp handle_add_badge_result(
         {:ok, _account},
         account_id,
         badge,
         quest,
         quest_badges,
         total_badges_in_quest,
         live,
         socket
       ) do
    Logger.info("Badge added to account successfully.")

    update_account_and_assign_badges(
      account_id,
      badge,
      quest,
      quest_badges,
      total_badges_in_quest,
      live,
      socket
    )
  end

  defp handle_add_badge_result(
         {:error, reason},
         _account_id,
         _badge,
         _quest,
         _quest_badges,
         _total_badges_in_quest,
         _live,
         socket
       ) do
    log_error("Failed to add badge to account: #{reason}")
    {:noreply, assign(socket, :error, true)}
  end

  defp update_account_and_assign_badges(
         account_id,
         badge,
         quest,
         quest_badges,
         total_badges_in_quest,
         live,
         socket
       ) do
    {:ok, updated_account} = fetch_account(account_id)
    shared_badges_count = count_shared_badges(updated_account.badges, quest_badges)
    badges_left = total_badges_in_quest - shared_badges_count

    socket =
      assign(socket, :badge, badge)
      |> assign(:quest, quest)
      |> assign(:badges_left, badges_left)
      |> assign(:total_badges_in_quest, total_badges_in_quest)
      |> assign(:live, live)

    # If its a loyalty badge
    if badge.loyalty_badge do
      total_transactions =
        QuestApiV21.GordianKnot.count_transactions_for_badge(account_id, badge.id)

      total_points = QuestApiV21.GordianKnot.count_points_for_badge(account_id, badge.id)
      # Fetch the next scan date
      next_scan_date = QuestApiV21.GordianKnot.get_next_scan_date(account_id, badge)

      case QuestApiV21.GordianKnot.get_next_reward(account_id, badge.id, quest) do
        {:ok, nil} ->
          {:noreply,
           socket
           |> assign(:is_loyalty_badge, true)
           |> assign(:total_transactions, total_transactions)
           |> assign(:total_points, total_points)
           |> assign(:next_reward_points, nil)
           |> assign(:next_reward, nil)
           |> assign(:next_scan_date, next_scan_date)}

        {:ok, {next_reward_points, next_reward}} ->
          {:noreply,
           socket
           |> assign(:is_loyalty_badge, true)
           |> assign(:total_transactions, total_transactions)
           |> assign(:total_points, total_points)
           |> assign(:next_reward_points, next_reward_points)
           |> assign(:next_reward, next_reward)
           |> assign(:next_scan_date, next_scan_date)}
      end
    else
      {:noreply, socket |> assign(:is_loyalty_badge, false)}
    end
  end

  defp count_shared_badges(account_badges, quest_badges) do
    account_badge_ids = Enum.map(account_badges, & &1.id)
    quest_badge_ids = Enum.map(quest_badges, & &1.id)

    shared_badges =
      Enum.filter(account_badge_ids, fn badge_id ->
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
      badge -> {:ok, Repo.preload(badge, :quest)}
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
      |> assign(collector: true)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= if @is_loyalty_badge do %>
        <.live_component
          module={QuestApiV21Web.LoyaltyBadgeDisplay}
          id="collected-loyalty-badge-details"
          badge={@badge}
          quest={@quest}
          error={@error}
          collector={@collector}
          total_transactions={@total_transactions}
          next_reward_points={@next_reward_points}
          next_reward={@next_reward}
          next_scan_date={@next_scan_date}
        />
        <p class="text-gold-100 mt-2 text-center ml-1">
          <%= if @next_reward do %>
            <%= @total_points %> points out of <%= @next_reward_points %>
          <% else %>
            You have <%= @total_points %> points!
          <% end %>
        </p>
        <.live_component
          module={QuestApiV21Web.LiveComponents.CollectorBar}
          badge={@badge}
          badges_left={@badges_left}
          live={@live}
          id="collector-bar"
        />
      <% else %>
        <.live_component
          module={QuestApiV21Web.BadgeDisplayComponent}
          id="collected-badge-details"
          badge={@badge}
          quest={@quest}
          error={@error}
          collector={@collector}
        />
        <%= unless @error do %>
          <p class="text-gold-100 mt-2 text-center ml-1">
            <%= if @badges_left > 0 do %>
              <%= @badges_left %> more left in the quest!
            <% else %>
              You completed the quest!
            <% end %>
          </p>
        <% end %>
        <.live_component
          module={QuestApiV21Web.LiveComponents.CollectorBar}
          badge={@badge}
          badges_left={@badges_left}
          live={@live}
          id="collector-bar"
        />
      <% end %>
      <%= unless @live do %>
        <p class="text-red-600 mt-2 text-center">This quest is no longer live</p>
      <% end %>
    </div>
    """
  end
end
