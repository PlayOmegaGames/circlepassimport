defmodule QuestApiV21.Repo.Migrations.AddRolesToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :role, :string
    end
  end
end
