defmodule QuestApiV21.Repo.Migrations.CreateHostsBusinesses do
  use Ecto.Migration

  def change do
    create table(:hosts_businesses) do
      add :host_id, references(:hosts, type: :binary_id, on_delete: :delete_all)
      add :business_id, references(:businesses, type: :binary_id, on_delete: :delete_all)
    end

    create unique_index(:hosts_businesses, [:host_id, :business_id])
  end
end
