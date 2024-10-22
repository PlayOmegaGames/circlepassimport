defmodule QuestApiV21.Repo.Migrations.AddSubscriptionsToOrganizations do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :subscription_tier, :string, default: "tier_free"
      add :subscription_date, :utc_datetime
      add :stripe_customer_id, :string
    end
  end
end
