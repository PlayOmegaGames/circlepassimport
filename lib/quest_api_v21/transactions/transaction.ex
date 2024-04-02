defmodule QuestApiV21.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :lp_badge, :integer
    field :lp_purchase, :integer
    field :lp_price, :integer
    belongs_to :organization, QuestApiV21.Organizations.Organization
    belongs_to :account, QuestApiV21.Accounts.Account
    belongs_to :badge, QuestApiV21.Badges.Badge
    belongs_to :quest, QuestApiV21.Quests.Quest

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :lp_badge,
      :lp_purchase,
      :lp_price,
      :organization_id,
      :account_id,
      :badge_id,
      :quest_id
    ])
    |> validate_required([])
  end
end
