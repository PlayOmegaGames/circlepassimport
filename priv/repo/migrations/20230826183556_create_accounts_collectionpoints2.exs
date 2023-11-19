defmodule QuestApiV21.Repo.Migrations.CreateAccountsbadges2 do
  use Ecto.Migration

  def change do
    create table(:badges_accounts) do
      add :account_id, references(:accounts, type: :binary_id)
      add :badge_id, references(:badge, type: :binary_id)  # Change this line
    end

    create unique_index(:badges_accounts, [:account_id])
  end
end
