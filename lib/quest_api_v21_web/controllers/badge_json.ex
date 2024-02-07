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

    @doc """
  Renders an error response.
  """
  def render("error.json", %{message: message}) do
    %{errors: %{detail: message}}
  end

  defp data(%Badge{accounts: accounts} = badge) do
    %{
      id: badge.id,
      name: badge.name,
      badge_image: badge.badge_image,
      scans: badge.scans,
      badge_details_image: badge.badge_details_image,
      badge_description: badge.badge_description,
      organization_id: badge.organization_id,
      quest_id: badge.quest_id,
      collector_id: badge.collector_id,
      badge_redirect: badge.badge_redirect,
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
