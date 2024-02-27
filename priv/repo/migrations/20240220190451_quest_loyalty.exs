defmodule QuestApiV21.Repo.Migrations.QuestLoyalty do
  use Ecto.Migration

  def change do
    alter table("quests") do
      add :completion_score, :integer
      add :event_name, :string
    end
  end
end
