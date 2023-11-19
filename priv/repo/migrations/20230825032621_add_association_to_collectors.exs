defmodule QuestApiV21.Repo.Migrations.AddAssociationToCollectors do
  use Ecto.Migration

  def change do
    alter table(:badge) do
      add :collector_id, references(:collectors, type: :binary_id, on_delete: :nothing)
    end

    create index(:badge, [:collector_id])

  end
end
