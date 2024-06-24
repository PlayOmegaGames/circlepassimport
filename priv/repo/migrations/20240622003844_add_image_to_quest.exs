defmodule QuestApiV21.Repo.Migrations.AddImageToQuest do
  use Ecto.Migration

  def change do
      alter table(:quests) do
        add :quest_image, :string
    end
  end
end
