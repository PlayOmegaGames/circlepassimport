defmodule QuestApiV21.Repo.Migrations.CreateScans do
  use Ecto.Migration

  def change do
    create table(:scans, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all)
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all)
      add :badge_id, references(:badge, type: :binary_id)

      timestamps()
    end
  end
end
