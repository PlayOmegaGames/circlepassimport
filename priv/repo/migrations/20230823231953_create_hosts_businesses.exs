defmodule QuestApiV21.Repo.Migrations.CreateHostsOrganizations do
  use Ecto.Migration

  def change do
    create table(:hosts_organizations) do
      add :host_id, references(:hosts, type: :binary_id, on_delete: :delete_all)
      add :orgaization_id, references(:organizations, type: :binary_id, on_delete: :delete_all)
    end

    create unique_index(:hosts_organizations, [:host_id, :orgaization_id])
  end
end
