defmodule QuestApiV21.Repo.Migrations.AddIsPasswordlessToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :is_passwordless, :boolean, default: false
    end
  end
end
