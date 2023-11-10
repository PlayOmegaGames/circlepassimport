defmodule QuestApiV21.Hosts.Host do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "hosts" do
    field :email, :string
    field :hashed_password, :string
    field :name, :string
    many_to_many :organizations, QuestApiV21.Organizations.Organization, join_through: "hosts_organizations"

    timestamps()
  end

  @doc false
  def changeset(host, attrs) do
    host
    |> cast(attrs, [:name, :email, :hashed_password])
    |> cast_assoc(:organizations, with: &QuestApiV21.Organizations.Organization.changeset/2)
    |> validate_required([:name, :email, :hashed_password])
  end
end
