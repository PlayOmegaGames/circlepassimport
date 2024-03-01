defmodule QuestApiV21.Repo.Migrations.AddCurrentQuestToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :selected_quest_id, references(:quests, type: :binary_id)
    end
  end
end
