defmodule QuestApiV21.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :name, :string
    field :subscription_tier, :string, default: "tier_free"
    field :stripe_customer_id, :string
    field :subscription_date, :utc_datetime
    many_to_many :hosts, QuestApiV21.Hosts.Host, join_through: "hosts_organizations"
    has_many :quests, QuestApiV21.Quests.Quest
    has_many :badges, QuestApiV21.Badges.Badge
    has_many :collectors, QuestApiV21.Collectors.Collector

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name])
    |> cast_assoc(:hosts, with: &QuestApiV21.Hosts.Host.changeset/2)
    |> validate_required([:name])
  end
end
