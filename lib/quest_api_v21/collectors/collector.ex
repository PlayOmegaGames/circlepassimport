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
    |> maybe_extract_and_set_quest_start(attrs)
    |> cast_assoc(:quests, with: &QuestApiV21.Quests.Quest.changeset/2)

  end

  #for Bubble
  defp maybe_extract_and_set_quest_start(changeset, attrs) do
    case Map.get(attrs, "name_id") do
      nil -> changeset
      name_id ->
        [_, quest_id] = String.split(name_id, " - ")
        change(changeset, %{quest_start: quest_id})
    end
  end
end
