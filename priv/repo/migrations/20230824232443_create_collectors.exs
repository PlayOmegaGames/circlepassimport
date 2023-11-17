defmodule QuestApiV21.Repo.Migrations.CreateCollectors do
  use Ecto.Migration

  def change do
    create table(:collectors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :coordinates, :string
      add :height, :string
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :nothing)

      timestamps()
    end
  end
end
