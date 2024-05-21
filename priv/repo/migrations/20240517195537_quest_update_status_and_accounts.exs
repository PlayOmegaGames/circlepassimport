defmodule QuestApiV21.Repo.Migrations.QuestUpdateStatusAndAccounts do
  use Ecto.Migration

  def change do
    alter table(:quests) do
      add :live, :boolean, default: true
    end
  end
end
