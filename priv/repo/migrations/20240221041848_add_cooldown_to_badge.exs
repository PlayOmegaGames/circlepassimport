defmodule QuestApiV21.Repo.Migrations.AddCooldownToBadge do
  use Ecto.Migration

  def change do
    alter table("badge") do
      add :badge_points, :integer, default: 10
      # default 24hrs
      add :cool_down_reset, :integer, default: 24
      add :share_location, :boolean, default: false
      add :hint, :string
    end
  end
end
