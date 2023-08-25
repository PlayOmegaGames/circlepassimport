defmodule QuestApiV21.Collection_Points.Collection_Point do
  use Ecto.Schema
  import Ecto.Changeset

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

    timestamps()
  end

  @doc false
  def changeset(collection__point, attrs) do
    collection__point
    |> cast(attrs, [:name, :image, :scans, :redirect_url, :badge_description, :business_id, :quest_id, :collector_id])
    |> validate_required([:name, :image, :redirect_url])
  end
end
