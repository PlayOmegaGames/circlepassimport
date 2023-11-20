defmodule QuestApiV21.Repo.Migrations.AddQuestStartToCollectors do
  use Ecto.Migration

  def change do
    alter table(:collectors) do
      add :quest_start, :string
    end
  end
end
