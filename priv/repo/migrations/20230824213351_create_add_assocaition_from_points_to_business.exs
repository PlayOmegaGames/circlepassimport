defmodule QuestApiV21.Repo.Migrations.CreateAddAssocaitionFromPointsToOrganization do
  use Ecto.Migration

  def change do
    alter table(:badge) do
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :nothing)
    end

    create index(:badge, [:organization_id])

  end
end
