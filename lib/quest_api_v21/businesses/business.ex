defmodule QuestApiV21.Businesses.Business do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "businesses" do
    field :name, :string
    many_to_many :hosts, QuestApiV21.Hosts.Host, join_through: "hosts_businesses"
    has_many :quests, QuestApiV21.Quests.Quest
    has_many :collection_points, QuestApiV21.Collection_Points.Collection_Point

    timestamps()
  end

  @doc false
  def changeset(business, attrs) do
    business
    |> cast(attrs, [:name])
    |> cast_assoc(:hosts, with: &QuestApiV21.Hosts.Host.changeset/2)
    |> validate_required([:name])
  end
end
