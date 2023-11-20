defmodule QuestApiV21Web.BadgeJSON do
  alias QuestApiV21.Badges.Badge
  alias QuestApiV21.Accounts.Account

  @doc """
  Renders a list of badge.
  """
  def index(%{badge: badge}) do
    %{data: for(badge <- badge, do: data(badge))}
  end

  @doc """
  Renders a single badge.
  """
  def show(%{badge: badge}) do
    %{data: data(badge)}
  end

  defp data(%Badge{accounts: accounts} = badge) do
    %{
      id: badge.id,
      name: badge.name,
      image: badge.image,
      scans: badge.scans,
      redirect_url: badge.redirect_url,
      badge_description: badge.badge_description,
      organization_id: badge.organization_id,
      quest_id: badge.quest_id,
      collector_id: badge.collector_id,
      unauthorized_url: badge.unauthorized_url,
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
