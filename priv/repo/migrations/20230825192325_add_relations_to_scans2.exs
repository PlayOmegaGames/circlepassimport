defmodule QuestApiV21.Repo.Migrations.AddRelationsToScans2 do
  use Ecto.Migration

  def change do
    alter table(:scans) do
      add :business_id, references(:businesses, type: :binary_id, on_delete: :nothing)
      add :collection_point_id, references(:collection_point, type: :binary_id)
    end

  end
end
