defmodule QuestApiV21.Repo.Migrations.CreateAddAssocaitionFromPointsToBusiness do
  use Ecto.Migration

  def change do
    alter table(:badge) do
      add :business_id, references(:businesses, type: :binary_id, on_delete: :nothing)
    end

    create index(:badge, [:business_id])

  end
end
