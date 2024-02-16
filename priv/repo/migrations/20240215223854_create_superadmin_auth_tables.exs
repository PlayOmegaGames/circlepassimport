defmodule QuestApiV21.Repo.Migrations.CreateSuperadminAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:superadmin, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:superadmin, [:email])

    create table(:superadmin_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :superadmin_id, references(:superadmin, type: :binary_id, on_delete: :delete_all),
        null: false

      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:superadmin_tokens, [:superadmin_id])
    create unique_index(:superadmin_tokens, [:context, :token])
  end
end
