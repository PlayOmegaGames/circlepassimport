defmodule QuestApiV21.Repo.Migrations.AddRelationsToScans2 do
  use Ecto.Migration

  def change do
    alter table(:scans) do
      add :orgaization_id, references(:organizations, type: :binary_id, on_delete: :nothing)
      add :badge_id, references(:badge, type: :binary_id)
    end

  end
end
