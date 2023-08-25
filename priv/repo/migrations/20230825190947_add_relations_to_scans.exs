defmodule QuestApiV21.Repo.Migrations.AddRelationsToScans do
  use Ecto.Migration

  def change do
    alter table(:scans) do
      add :account_id, references(:accounts, type: :binary_id, on_delete: :nothing)
    end

    create index(:scans, [:account_id])
  end

end
