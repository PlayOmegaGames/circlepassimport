defmodule QuestApiV21.Scans.Scan do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "scans" do
    belongs_to :organization, QuestApiV21.Organizations.Organization
    belongs_to :account, QuestApiV21.Accounts.Account
    belongs_to :badge, QuestApiV21.Badges.Badge



    timestamps()
  end

  @doc false
  def changeset(scan, attrs) do
    scan
    |> cast(attrs, [:organization_id, :account_id, :badge_id])
    |> validate_required([])
  end
end
