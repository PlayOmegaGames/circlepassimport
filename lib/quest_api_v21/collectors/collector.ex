defmodule QuestApiV21.Collectors.Collector do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "collectors" do
    field :coordinates, :string
    field :height, :string
    field :name, :string
    field :quest_start, :string
    belongs_to :organization, QuestApiV21.Organizations.Organization
    has_many :badges, QuestApiV21.Badges.Badge
    many_to_many :quests, QuestApiV21.Quests.Quest, join_through: "quests_collectors"

    timestamps()
  end

  @doc false
  def changeset(collector, attrs) do
    collector
    |> cast(attrs, [:name, :coordinates, :height, :quest_start, :organization_id])
    |> validate_required([:name])
    |> cast_assoc(:quests, with: &QuestApiV21.Quests.Quest.changeset/2)

  end
end
