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

      timestamps()
    end
  end
end
