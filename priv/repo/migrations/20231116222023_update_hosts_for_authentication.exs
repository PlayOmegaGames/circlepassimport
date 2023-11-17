defmodule QuestApiV21.Repo.Migrations.UpdateHostsForAuthentication do
  use Ecto.Migration

  def change do
    alter table(:hosts) do
      add :password, :string, virtual: true  # Virtual field for the plaintext password
      add :role, :string, default: "default"  # If you want to include roles like in the Account schema
    end
  end
end
