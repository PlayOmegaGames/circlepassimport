defmodule QuestApiV21.Repo.Migrations.AddDescriptionToQuest do
  use Ecto.Migration

  def change do
    alter table(:quests) do
      add :description, :string
    end
  end
end
