defmodule QuestApiV21.Repo.Migrations.LoyaltyBadgeUpdate do
  use Ecto.Migration

  def change do
    alter table("badge") do
      add :loyalty_badge, :boolean, default: false
    end
  end
end
