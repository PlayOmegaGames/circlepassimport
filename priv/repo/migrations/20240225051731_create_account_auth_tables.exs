defmodule QuestApiV21.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :confirmed_at, :naive_datetime
    end

    create unique_index(:accounts, [:email])

    create table(:accounts_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all),
        null: false

      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:accounts_tokens, [:account_id])
    create unique_index(:accounts_tokens, [:context, :token])
  end
end
