defmodule QuestApiV21.Repo.Migrations.RenameRewardToRewards do
  use Ecto.Migration

  def change do
    rename table("reward"), to: table("rewards")
  end
end
