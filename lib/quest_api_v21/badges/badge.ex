defmodule QuestApiV21.Badges.Badge do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "badge" do
    field :badge_description, :string
    field :badge_image, :string
    field :name, :string
    field :badge_details_image, :string
    field :scans, :integer, default: 0
    field :badge_redirect, :string
    belongs_to :organization, QuestApiV21.Organizations.Organization
    belongs_to :quest, QuestApiV21.Quests.Quest
    belongs_to :collector, QuestApiV21.Collectors.Collector
    many_to_many :accounts, QuestApiV21.Accounts.Account, join_through: "badges_accounts"
    many_to_many :tags, QuestApiV21.Tags.Tag, join_through: "badges_tags"

    timestamps()
  end

  @doc false
  def changeset(badge, attrs) do

    badge
    |> cast(attrs, [:name, :badge_image, :scans, :badge_details_image, :badge_description, :badge_redirect, :organization_id, :quest_id, :collector_id])
    |> validate_required([:name, :badge_image, :badge_details_image])
    |> cast_assoc(:accounts, with: &QuestApiV21.Accounts.Account.changeset/2)

  end


end
