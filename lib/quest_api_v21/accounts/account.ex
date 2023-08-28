defmodule QuestApiV21.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :email, :string
    field :hashed_passowrd, :string
    field :name, :string
    many_to_many :collection_points, QuestApiV21.Collection_Points.Collection_Point, join_through: "collectionpoints_accounts"

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :email, :hashed_passowrd])
    |> validate_required([:name, :email, :hashed_passowrd])
    |> cast_assoc(:collection_points, with: &QuestApiV21.Collection_Points.Collection_Point.changeset/2)

  end
end
