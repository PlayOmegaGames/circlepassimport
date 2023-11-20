defmodule QuestApiV21.Quests.Quest do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quests" do
    field :address, :string
    field :end_date, :date
    field :name, :string
    field :quest_type, :string, default: "Treasure Hunt"
    field :redemption, :string
    field :reward, :string
    field :scans, :integer, default: 0
    field :start_date, :date
    field :description, :string
    belongs_to :organization, QuestApiV21.Organizations.Organization
    has_many :badges, QuestApiV21.Badges.Badge
    many_to_many :collectors, QuestApiV21.Collectors.Collector, join_through: "quests_collectors"


    timestamps()
  end

  @doc false
  def changeset(quest, attrs) do
    quest
    |> cast(attrs, [:name, :scans, :quest_type, :reward, :redemption, :start_date, :description, :end_date, :address, :organization_id])
    |> validate_required([:name, :reward, :address, :organization_id])
    |> cast_assoc(:badges, with: &QuestApiV21.Badges.Badge.changeset/2)
    |> cast_assoc(:collectors, with: &QuestApiV21.Collectors.Collector.changeset/2)

    |> assoc_constraint(:organization)
  end
end
