defmodule QuestApiV21.Repo.Migrations.AddCollectionPointIdToAccountsCollectionpoints do
  use Ecto.Migration

  def change do
    alter table(:accounts_collectionpoints) do
      add :collection__point_id, references(:collection_point, type: :binary_id)
    end
  end
end
