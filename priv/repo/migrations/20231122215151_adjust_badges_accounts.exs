defmodule QuestApiV21.Repo.Migrations.AdjustBadgesAccounts do
  use Ecto.Migration

  def change do
    drop unique_index(:badges_accounts, [:account_id])

    create unique_index(:badges_accounts, [:account_id, :badge_id])
  end
end
