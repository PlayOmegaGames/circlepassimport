defmodule QuestApiV21.Repo.Migrations.AddOrganizationToQuests do
  use Ecto.Migration

  def change do
    alter table(:quests) do
      add :orgaization_id, references(:organizations, type: :binary_id, on_delete: :nothing)
    end

    create index(:quests, [:orgaization_id])

  end
end
