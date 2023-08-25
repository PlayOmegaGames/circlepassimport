defmodule QuestApiV21.Repo.Migrations.AddAssociationToCollectors do
  use Ecto.Migration

  def change do
    alter table(:collection_point) do
      add :collector_id, references(:collectors, type: :binary_id, on_delete: :nothing)
    end

    create index(:collection_point, [:collector_id])

  end
end
