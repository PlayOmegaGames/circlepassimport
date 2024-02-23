defmodule QuestApiV21.Repo.Migrations.AddedCurrentOrgToHosts do
  use Ecto.Migration

  def change do
    alter table(:hosts) do
      add :current_org_id, references(:organizations, type: :binary_id)
    end
  end
end
