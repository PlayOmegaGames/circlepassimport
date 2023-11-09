defmodule QuestApiV21.Repo.Migrations.AddCollectionPointIdToAccountsCollectionpoints do
  use Ecto.Migration

  def change do
    alter table(:accounts_collectionpoints) do
      add :badge_id, references(:badge, type: :binary_id)
    end
  end
end
