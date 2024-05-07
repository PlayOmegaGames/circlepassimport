defmodule QuestApiV21Web.BadgeJSON do
  alias QuestApiV21.Badges.Badge
  alias QuestApiV21.Accounts.Account

  @doc """
  Renders a list of badges.
  """
  def index(%{badges: badges}) do
    %{data: for(badges <- badges, do: data(badges))}
  end

  @doc """
  Renders a single badges.
  """
  def show(%{badge: badges}) do
    %{data: data(badges)}
  end

  @doc """
  Renders an error response.
  """
  def render("error.json", %{message: message}) do
    %{errors: %{detail: message}}
  end

  defp data(%Badge{accounts: accounts} = badges) do
    %{
      id: badges.id,
      name: badges.name,
      badge_image: badges.badge_image,
      scans: badges.scans,
      badge_details_image: badges.badge_details_image,
      badge_description: badges.badge_description,
      organization_id: badges.organization_id,
      quest_id: badges.quest_id,
      badge_points: badges.badge_points,
      cool_down_reset: badges.cool_down_reset,
      share_location: badges.share_location,
      hint: badges.hint,
      collector_id: badges.collector_id,
      badge_redirect: badges.badge_redirect,
      badge_loyalty: badges.loyalty_badge,
      account_ids: accounts_data(accounts)
    }
  end

  defp accounts_data(accounts) do
    Enum.map(accounts, fn %Account{id: id} ->
      %{
        id: id
      }
    end)
  end
end
