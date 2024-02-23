defmodule QuestApiV21.Repo.Migrations.CreateRewards do
  use Ecto.Migration

  def change do
    create table(:reward, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :reward_name, :string
      add :public, :boolean, default: false
      add :organization_id, references(:organizations, type: :binary_id)
      add :account_id, references(:accounts, type: :binary_id)
      add :quest_id, references(:quests, type: :binary_id)
      add :slug, :string

      timestamps()
    end
  end
end
