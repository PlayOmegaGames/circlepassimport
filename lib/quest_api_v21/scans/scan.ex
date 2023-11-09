defmodule QuestApiV21.Scans.Scan do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "scans" do
    belongs_to :business, QuestApiV21.Businesses.Business
    belongs_to :account, QuestApiV21.Accounts.Account
    belongs_to :badge, QuestApiV21.Badges.Badge



    timestamps()
  end

  @doc false
  def changeset(scan, attrs) do
    scan
    |> cast(attrs, [:business_id, :account_id, :badge_id])
    |> validate_required([])
  end
end
