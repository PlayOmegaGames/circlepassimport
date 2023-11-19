defmodule QuestApiV21.Repo.Migrations.AddCollectionPointIdToAccountsbadges do
  use Ecto.Migration

  def change do
    alter table(:accounts_badges) do
      add :badge_id, references(:badge, type: :binary_id)
    end
  end
end
