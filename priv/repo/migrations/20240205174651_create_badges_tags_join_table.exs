defmodule QuestApiV21.Repo.Migrations.CreateBadgesTagsJoinTable do
  use Ecto.Migration

  def change do
    create table(:badges_tags, primary_key: false) do
      add :badge_id, references(:badge, type: :binary_id, on_delete: :delete_all)
      add :tag_id, references(:tags, type: :binary_id, on_delete: :delete_all)
    end

    create index(:badges_tags, [:badge_id])
    create index(:badges_tags, [:tag_id])
  end
end
