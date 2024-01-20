defmodule QuestApiV21.Repo.Migrations.AddQuestDiscountCode do
  use Ecto.Migration

  def change do
    alter table(:quests) do
      add :discount_code, :string
    end
  end
end
