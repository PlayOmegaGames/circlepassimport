defmodule QuestApiV21.Repo.Migrations.AddBadgeCountToQuests do
  use Ecto.Migration

  def change do
    alter table(:quests) do
      add :badge_count, :integer, default: 0
    end
  end
end
