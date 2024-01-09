defmodule QuestApiV21.Repo.Migrations.CreateQuests do
  use Ecto.Migration

  def change do
    create table(:quests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :scans, :integer
      add :quest_type, :string
      add :reward, :string
      add :redemption, :text
      add :start_date, :date
      add :end_date, :date
      add :address, :string
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all)
      add :quest_id, references(:quests, type: :binary_id, on_delete: :delete_all)
      add :description, :string

      timestamps()
    end
  end
end
