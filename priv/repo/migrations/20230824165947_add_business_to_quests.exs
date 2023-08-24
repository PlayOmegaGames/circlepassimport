defmodule QuestApiV21.Repo.Migrations.AddBusinessToQuests do
  use Ecto.Migration

  def change do
    alter table(:quests) do
      add :business_id, references(:businesses, type: :binary_id, on_delete: :nothing)
    end

    create index(:quests, [:business_id])

  end
end
