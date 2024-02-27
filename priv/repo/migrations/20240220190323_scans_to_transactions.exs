defmodule QuestApiV21.Repo.Migrations.TransactionsToTransactions do
  use Ecto.Migration

  def change do
    rename table("transactions"), to: table("transactions")

    alter table("transactions") do
      add :quest_id, references(:quests, type: :binary_id)
      add :lp_badge, :integer
      add :lp_purchase, :integer
      add :lp_price, :integer
    end
  end
end
