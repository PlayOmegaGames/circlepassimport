defmodule QuestApiV21.Repo.Migrations.CreateAccountsbadges do
  use Ecto.Migration

  def change do
    create table(:accounts_badges) do
      add :account_id, references(:accounts, type: :binary_id)
      add :badge_id, references(:badge, type: :binary_id)  # Change this line
    end

    create unique_index(:accounts_badges, [:account_id])
  end
end
