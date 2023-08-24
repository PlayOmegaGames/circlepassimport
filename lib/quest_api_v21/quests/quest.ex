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
    belongs_to :business, QuestApiV21.Businesses.Business

    timestamps()
  end

  @doc false
  def changeset(quest, attrs) do
    quest
    |> cast(attrs, [:name, :scans, :quest_type, :reward, :redemption, :start_date, :end_date, :address, :business_id])
    |> validate_required([:name, :reward, :address])
    |> assoc_constraint(:business)
  end
end
