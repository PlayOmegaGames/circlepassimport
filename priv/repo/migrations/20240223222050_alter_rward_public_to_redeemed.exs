defmodule QuestApiV21.Repo.Migrations.AlterRwardPublicToRedeemed do
  use Ecto.Migration

  def change do
    rename table(:rewards), :public, to: :redeemed
  end
end
