defmodule QuestApiV21.Repo.Migrations.CreateScans do
  use Ecto.Migration

  def change do
    create table(:scans, primary_key: false) do
      add :id, :binary_id, primary_key: true


      timestamps()
    end
  end
end
