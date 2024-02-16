defmodule QuestApiV21.Repo.Migrations.CreateQuestsAccounts do
  use Ecto.Migration

  def change do
    create table(:quests_accounts, primary_key: false) do
      add :quest_id, references(:quests, on_delete: :delete_all, type: :binary_id)
      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id)
    end

    # Optionally, you can add an index to improve query performance.
    create index(:quests_accounts, [:quest_id])
    create index(:quests_accounts, [:account_id])

    # To ensure uniqueness and avoid duplicate entries
    create unique_index(:quests_accounts, [:quest_id, :account_id])
  end
end
