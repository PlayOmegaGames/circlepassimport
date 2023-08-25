defmodule QuestApiV21.Scans.Scan do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "scans" do
    belongs_to :business, QuestApiV21.Businesses.Business
    belongs_to :account, QuestApiV21.Accounts.Account
    belongs_to :collection_point, QuestApiV21.Collection_Points.Collection_Point



    timestamps()
  end

  @doc false
  def changeset(scan, attrs) do
    scan
    |> cast(attrs, [:business_id, :account_id, :collection_point_id])
    |> validate_required([])
  end
end
