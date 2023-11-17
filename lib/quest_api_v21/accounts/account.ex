defmodule QuestApiV21.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query  # <-- To use Ecto queries in this module

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :email, :string
    field :hashed_password, :string
    field :password, :string, virtual: true  # Virtual field for the plaintext password so that it isn't stored in the database
    field :name, :string
    field :role, :string, default: "default"
    many_to_many :badges, QuestApiV21.Badges.Badge, join_through: "collectionpoints_accounts", join_keys: [account_id: :id, collectionpoint_id: :id]

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    badges = prepare_badges(attrs)  # Fetch and validate badges based on IDs

    account
    |> cast(attrs, [:name, :email, :hashed_password, :password, :role])
    |> validate_required([:name, :email])
    |> put_assoc(:badges, badges)
  end

  defp prepare_badges(attrs) do
    badge_ids = Map.get(attrs, "badges", [])
    QuestApiV21.Repo.all(from cp in QuestApiV21.Badges.Badge, where: cp.id in ^badge_ids)
  end
end
