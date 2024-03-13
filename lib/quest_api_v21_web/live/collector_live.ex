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

          case QuestApiV21.Accounts.add_badge_to_account(account.id, badge.id) do
            {:ok, "Badge already associated with the account"} ->
              Logger.info("Badge was already collected")
              {:noreply, assign(socket, :badge, badge)}

            {:ok, _account} ->
              Logger.info("Badge added to account successfully.")
              # Here, update the socket with any necessary information. If the quest was updated as a result,
              # you might need to re-fetch the account or quest information to reflect the changes.
              # This example just assigns the badge. You might need to adjust based on your app's logic.
              {:noreply, assign(socket, :badge, badge)}

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


  defp fetch_collector(uuid) do
    case Collectors.get_collector(uuid) |> Repo.preload([:quests, :badges]) do
      nil -> {:error, "Collector not found."}
      collector -> {:ok, collector}
    end
  end

  defp fetch_account(account_id) do
    case Repo.get!(QuestApiV21.Accounts.Account, account_id) |> Repo.preload(:quests) do
      nil -> {:error, "Account not found."}
      account -> {:ok, account}
    end
  end

  defp fetch_last_badge(badges) do
    case Enum.at(badges, -1) do
      nil -> {:error, "Collector has no badges."}
      badge -> {:ok, badge}
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
      |> assign(account: current_account)

    {:ok, socket}
  end



  def render(assigns) do

  ~H"""
    <div>

      <%= if @error do %>
        Badge Not Found
      <% else %>
          Hi

          <img src={@badge.badge_image} />
      <% end %>

    </div>
  """
  end

end
