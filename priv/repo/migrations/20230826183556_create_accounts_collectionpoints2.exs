defmodule QuestApiV21.Repo.Migrations.CreateAccountsCollectionpoints2 do
  use Ecto.Migration

  def change do
    create table(:collectionpoints_accounts) do
      add :account_id, references(:accounts, type: :binary_id)
      add :collectionpoint_id, references(:badge, type: :binary_id)  # Change this line
    end

    create unique_index(:collectionpoints_accounts, [:account_id])
  end
end
