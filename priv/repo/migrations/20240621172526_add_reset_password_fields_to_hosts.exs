defmodule QuestApiV21.Repo.Migrations.AddResetPasswordFieldsToHosts do
  use Ecto.Migration

  def change do
    alter table(:hosts) do
      add :reset_password_token, :string
      add :reset_password_sent_at, :naive_datetime
    end

    create unique_index(:hosts, [:email])
    create unique_index(:hosts, [:reset_password_token])

    create table(:hosts_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :host_id, references(:hosts, type: :uuid, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:hosts_tokens, [:host_id])
    create unique_index(:hosts_tokens, [:context, :token])
  end
end
