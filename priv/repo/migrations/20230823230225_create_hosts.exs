defmodule QuestApiV21.Repo.Migrations.CreateHosts do
  use Ecto.Migration

  def change do
    create table(:hosts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :string
      add :hashed_password, :string

      timestamps()
    end
  end
end
