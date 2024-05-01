defmodule QuestApiV21.Repo.Migrations.AddQuestLoyaltyToQuest do
  use Ecto.Migration

  def change do
    alter table("quests") do
      add :quest_loyalty, :string
    end
  end
end
