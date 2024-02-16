defmodule QuestApiV21.Hosts.Host do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "hosts" do
    field :email, :string
    field :hashed_password, :string
    # Virtual field for the plaintext password
    field :password, :string, virtual: true
    field :name, :string
    field :role, :string, default: "default"

    many_to_many :organizations, QuestApiV21.Organizations.Organization,
      join_through: "hosts_organizations"

    timestamps()
  end

  @doc false
  def changeset(host, attrs) do
    host
    # Include password and role in the cast
    |> cast(attrs, [:name, :email, :hashed_password, :password, :role])
    |> validate_required([:name, :email])
    |> cast_assoc(:organizations, with: &QuestApiV21.Organizations.Organization.changeset/2)
  end
end
