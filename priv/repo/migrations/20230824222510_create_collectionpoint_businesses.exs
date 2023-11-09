defmodule QuestApiV21.Repo.Migrations.CreateCollectionpointQuest do
  use Ecto.Migration

  def change do
    create table(:collectionpoint_quests) do
      add :badge_id, references(:badge, type: :binary_id)
      add :quest_id, references(:quests, type: :binary_id)
    end

    create unique_index(:collectionpoint_quests, [:quest_id, :badge_id])
  end
end
