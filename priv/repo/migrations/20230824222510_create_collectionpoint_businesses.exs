defmodule QuestApiV21.Repo.Migrations.CreateCollectionpointQuest do
  use Ecto.Migration

  def change do
    create table(:collectionpoint_quests) do
      add :collection_point_id, references(:collection_point, type: :binary_id)
      add :quest_id, references(:quests, type: :binary_id)
    end

    create unique_index(:collectionpoint_quests, [:quest_id, :collection_point_id])
  end
end
