defmodule QuestApiV21.Repo.Migrations.CreateQuestsCollectors do
  use Ecto.Migration

  def change do
    create table(:quests_collectors) do
      add :collector_id, references(:collectors, type: :binary_id)
      add :quest_id, references(:quests, type: :binary_id)
    end

    create unique_index(:quests_collectors, [:collector_id, :quest_id])
  end
end
