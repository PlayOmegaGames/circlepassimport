defmodule QuestApiV21.Badges.Badge do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "badge" do
    field :badge_description, :string
    field :image, :string
    field :name, :string
    field :redirect_url, :string
    field :scans, :integer, default: 0
    field :unauthorized_url, :string
    belongs_to :organization, QuestApiV21.Organizations.Organization
    belongs_to :quest, QuestApiV21.Quests.Quest
    belongs_to :collector, QuestApiV21.Collectors.Collector
    many_to_many :accounts, QuestApiV21.Accounts.Account, join_through: "badges_accounts"

    timestamps()
  end

  @doc false
  def changeset(badge, attrs) do

    badge
    |> cast(attrs, [:name, :image, :scans, :redirect_url, :badge_description, :unauthorized_url, :organization_id, :quest_id, :collector_id])
    |> validate_required([:name, :image, :redirect_url])
    |> cast_assoc(:accounts, with: &QuestApiV21.Accounts.Account.changeset/2)

  end


end
