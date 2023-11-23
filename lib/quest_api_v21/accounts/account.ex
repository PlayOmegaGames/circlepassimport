defmodule QuestApiV21.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :email, :string
    field :hashed_password, :string, default: nil
    field :is_passwordless, :boolean, default: false
    field :password, :string, virtual: true  # Virtual field for the plaintext password so that it isn't stored in the database
    field :name, :string
    field :role, :string, default: "default"
    many_to_many :badges, QuestApiV21.Badges.Badge, join_through: "badges_accounts"
    many_to_many :quests, QuestApiV21.Quests.Quest, join_through: "quests_accounts"

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do

    account
    |> cast(attrs, [:name, :email, :hashed_password, :password, :role, :is_passwordless])
    |> validate_required([:name, :email])
    |> cast_assoc(:badges, with: &QuestApiV21.Badges.Badge.changeset/2)
    |> cast_assoc(:quests, with: &QuestApiV21.Quests.Quest.changeset/2)
  end

end
