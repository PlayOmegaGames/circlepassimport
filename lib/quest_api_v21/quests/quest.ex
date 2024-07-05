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
    field :completion_score, :integer
    field :event_name, :string
    field :badge_count, :integer
    field :quest_loyalty, :string
    field :quest_image, :string
    field :live, :boolean, default: true
    belongs_to :organization, QuestApiV21.Organizations.Organization
    has_many :badges, QuestApiV21.Badges.Badge
    many_to_many :collectors, QuestApiV21.Collectors.Collector, join_through: "quests_collectors"
    many_to_many :accounts, QuestApiV21.Accounts.Account, join_through: "quests_accounts"
    timestamps()
  end

  @doc false
  def changeset(quest, attrs) do
    # Preprocess the quest_loyalty field
    attrs =
      case Map.fetch(attrs, "quest_loyalty") do
        {:ok, loyalty_map} when is_map(loyalty_map) ->
          Map.put(attrs, "quest_loyalty", Jason.encode!(loyalty_map))

        _ ->
          attrs
      end

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
      :organization_id,
      :completion_score,
      :event_name,
      :quest_loyalty,
      :live,
      :badge_count
    ])
    |> validate_required([:name, :organization_id])
    |> cast_assoc(:badges, with: &QuestApiV21.Badges.Badge.changeset/2)
    |> cast_assoc(:collectors, with: &QuestApiV21.Collectors.Collector.changeset/2)
    |> assoc_constraint(:organization)
    |> update_quest_type()
  end

  defp update_quest_type(changeset) do
    case fetch_change(changeset, :quest_loyalty) do
      {:ok, _} ->
        put_change(changeset, :quest_type, "loyalty")

      _ ->
        changeset
    end
  end
end
