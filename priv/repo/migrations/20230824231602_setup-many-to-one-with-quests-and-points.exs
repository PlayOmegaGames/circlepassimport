defmodule :"Elixir.QuestApiV21.Repo.Migrations.Setup-many-to-one-with-quests-and-points" do
  use Ecto.Migration

  def change do
    alter table(:collection_point) do
      add :quest_id, references(:quests, type: :binary_id, on_delete: :nothing)
    end

    create index(:collection_point, [:quest_id])

  end
end
