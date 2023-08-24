defmodule QuestApiV21.Hosts.Host do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "hosts" do
    field :email, :string
    field :hashed_password, :string
    field :name, :string
    many_to_many :businesses, QuestApiV21.Businesses.Business, join_through: "hosts_businesses"

    timestamps()
  end

  @doc false
  def changeset(host, attrs) do
    host
    |> cast(attrs, [:name, :email, :hashed_password])
    |> cast_assoc(:businesses, with: &QuestApiV21.Businesses.Business.changeset/2)
    |> validate_required([:name, :email, :hashed_password])
  end
end
