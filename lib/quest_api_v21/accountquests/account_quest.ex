defmodule QuestApiV21.Accountquests.AccountQuest do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accountquest" do
    field :badge_count, :integer
    field :loyalty_points, :integer
    belongs_to :quest, QuestApiV21.Quests.Quest
    belongs_to :account, QuestApiV21.Accounts.Account

    timestamps()
  end

  @doc false
  def changeset(account_quest, attrs) do
    account_quest
    |> cast(attrs, [:loyalty_points, :badge_count, :quest_id, :account_id])
  end
end
