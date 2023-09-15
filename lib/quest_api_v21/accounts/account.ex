defmodule QuestApiV21.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query  # <-- Add this line if you plan to use Ecto queries in this module

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :email, :string
    field :hashed_passowrd, :string
    field :name, :string
    many_to_many :collection_points, QuestApiV21.Collection_Points.Collection_Point, join_through: "collectionpoints_accounts", join_keys: [account_id: :id, collectionpoint_id: :id]

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    collection_points = prepare_collection_points(attrs)  # Fetch and validate collection_points based on IDs

    account
    |> cast(attrs, [:name, :email, :hashed_passowrd])
    |> validate_required([:name, :email, :hashed_passowrd])
    |> put_assoc(:collection_points, collection_points)  # Use put_assoc for existing collection_points
  end

  defp prepare_collection_points(attrs) do
    collection_point_ids = Map.get(attrs, "collection_points", [])
    QuestApiV21.Repo.all(from cp in QuestApiV21.Collection_Points.Collection_Point, where: cp.id in ^collection_point_ids)
  end
end
