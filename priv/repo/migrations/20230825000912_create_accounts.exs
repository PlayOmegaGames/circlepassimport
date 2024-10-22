defmodule QuestApiV21.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :string
      add :hashed_passowrd, :string
      add :role, :string
      add :is_passwordless, :boolean, default: false

      timestamps()
    end
  end
end
