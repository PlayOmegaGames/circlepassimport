defmodule QuestApiV21.Rewards.Reward do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rewards" do
    field :redeemed, :boolean, default: false
    field :reward_name, :string
    field :slug, :string
    belongs_to :organization, QuestApiV21.Organizations.Organization
    belongs_to :account, QuestApiV21.Accounts.Account
    belongs_to :quest, QuestApiV21.Quests.Quest

    timestamps()
  end

  @doc false
  def changeset(reward, attrs) do
    reward
    |> cast(attrs, [:reward_name, :redeemed, :slug, :organization_id, :quest_id, :account_id])
    |> validate_required([:reward_name, :account_id])
    |> redemption_code()
  end

  defp redemption_code(changeset) do
    reward_name = get_field(changeset, :reward_name)
    account_id = get_field(changeset, :account_id)
    slug = Slugy.slugify(reward_name)
    id = String.slice(account_id, -6..-1)
    put_change(changeset, :slug, "#{slug}-#{id}")
  end

end
