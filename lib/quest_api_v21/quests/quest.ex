defmodule QuestApiV21.Quests.Quest do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quests" do
    field :address, :string
    field :address_url, :string
    field :start_date, :date
    field :end_date, :date
    field :name, :string
    field :quest_type, :string, default: "Treasure Hunt"
    field :redemption, :string
    field :discount_code, :string
    field :reward, :string
    field :scans, :integer, default: 0
    field :description, :string
    field :public, :boolean
    field :quest_time, :string

    belongs_to :organization, QuestApiV21.Organizations.Organization
    has_many :badges, QuestApiV21.Badges.Badge
    many_to_many :collectors, QuestApiV21.Collectors.Collector, join_through: "quests_collectors"
    many_to_many :accounts, QuestApiV21.Accounts.Account, join_through: "quests_accounts"

    timestamps()
  end

  @doc false
  def changeset(quest, attrs) do
    quest
    |> cast(attrs, [
      :address,
      :address_url,
      :start_date,
      :end_date,
      :name,
      :quest_type,
      :redemption,
      :discount_code,
      :reward,
      :scans,
      :description,
      :public,
      :quest_time,
      :organization_id
    ])
    |> validate_required([:name, :organization_id])
    |> cast_assoc(:badges, with: &QuestApiV21.Badges.Badge.changeset/2)
    |> cast_assoc(:collectors, with: &QuestApiV21.Collectors.Collector.changeset/2)
    |> assoc_constraint(:organization)
  end
end
