defmodule QuestApiV21.Repo.Migrations.CreateAccountsCollectionpoints do
  use Ecto.Migration

  def change do
    create table(:accounts_collectionpoints) do
      add :account_id, references(:accounts, type: :binary_id)
      add :collectionpoint_id, references(:badge, type: :binary_id)  # Change this line
    end

    create unique_index(:accounts_collectionpoints, [:account_id])
  end
end
