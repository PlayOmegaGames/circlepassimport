defmodule QuestApiV21.Repo.Migrations.AnimazeQuestAndAccountsUpdates do
  use Ecto.Migration

  def change do
    alter table(:quests) do
      add :address_url, :string
      add :public, :boolean, default: false
      add :quest_time, :string
    end

    alter table(:accounts) do
      add :quests_stats, :integer, default: 0
      add :badges_stats, :integer, default: 0
      add :rewards_stats, :integer, default: 0
      add :pfps, :string
    end
  end
end
