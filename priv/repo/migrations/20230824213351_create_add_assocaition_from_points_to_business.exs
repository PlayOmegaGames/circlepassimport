defmodule QuestApiV21.Repo.Migrations.CreateAddAssocaitionFromPointsToBusiness do
  use Ecto.Migration

  def change do
    alter table(:collection_point) do
      add :business_id, references(:businesses, type: :binary_id, on_delete: :nothing)
    end

    create index(:collection_point, [:business_id])

  end
end
