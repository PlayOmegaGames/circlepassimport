defmodule QuestApiV21.Collection_Points.Collection_Point do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "collection_point" do
    field :badge_description, :string
    field :image, :string
    field :name, :string
    field :redirect_url, :string
    field :scans, :integer, default: 0
    belongs_to :business, QuestApiV21.Businesses.Business
    belongs_to :quest, QuestApiV21.Quests.Quest
    belongs_to :collector, QuestApiV21.Collectors.Collector
    many_to_many :accounts, QuestApiV21.Accounts.Account, join_through: "collectionpoints_accounts", join_keys: [collectionpoint_id: :id, account_id: :id]

    timestamps()
  end

  @doc false
  def changeset(collection__point, attrs) do
    accounts = prepare_accounts(attrs)  # Fetch and validate accounts based on IDs

    collection__point
    |> cast(attrs, [:name, :image, :scans, :redirect_url, :badge_description, :business_id, :quest_id, :collector_id])
    |> validate_required([:name, :image, :redirect_url])
    |> put_assoc(:accounts, accounts)  # Use put_assoc for existing accounts
  end

  defp prepare_accounts(attrs) do
    account_ids = Map.get(attrs, "accounts", [])
    QuestApiV21.Repo.all(from a in QuestApiV21.Accounts.Account, where: a.id in ^account_ids)
  end
end
