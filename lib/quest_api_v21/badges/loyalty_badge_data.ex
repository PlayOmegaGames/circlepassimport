defmodule QuestApiV21.Badges.LoyaltyBadgeData do
  alias QuestApiV21.GordianKnot
  alias QuestApiV21.Repo

  def fetch_loyalty_data(account_id, badge) do
    badge = Repo.preload(badge, :quest)

    total_transactions = GordianKnot.count_transactions_for_badge(account_id, badge.id)
    total_points = GordianKnot.count_points_for_badge(account_id, badge.id)
    next_scan_date = GordianKnot.get_next_scan_date(account_id, badge)

    next_reward =
      case GordianKnot.get_next_reward(account_id, badge.id, badge.quest) do
        {:ok, nil} -> nil
        {:ok, {_next_reward_points, next_reward}} -> next_reward
      end

    %{
      total_transactions: total_transactions,
      total_points: total_points,
      next_scan_date: next_scan_date,
      next_reward: next_reward
    }
  end
end
