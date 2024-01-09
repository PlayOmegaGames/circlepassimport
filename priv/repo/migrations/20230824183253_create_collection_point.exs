defmodule QuestApiV21.Repo.Migrations.CreateCollectionPoint do
  use Ecto.Migration

  def change do
    create table(:badge, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :image, :string
      add :scans, :integer
      add :redirect_url, :string
      add :badge_description, :text
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all)
      add :quest_id, references(:quests, type: :binary_id, on_delete: :delete_all)
      add :collector_id, references(:collectors, type: :binary_id, on_delete: :delete_all)
      add :unauthorized_url, :string

      timestamps()
    end
  end
end
