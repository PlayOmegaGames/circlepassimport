defmodule QuestApiV21.Repo.Migrations.CreateAccountquest do
  use Ecto.Migration

  def change do
    create table(:accountquest, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :badge_count, :integer, default: 0
      add :loyalty_points, :integer, default: 0
      add :quest_id, references(:quests, type: :binary_id)

      timestamps()
    end
  end
end
