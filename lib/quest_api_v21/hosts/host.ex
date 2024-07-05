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
    field :password_confirmation, :string, virtual: true
    field :name, :string
    field :role, :string, default: "default"
    field :reset_password_token, :string
    field :reset_password_sent_at, :naive_datetime

    belongs_to :current_org, QuestApiV21.Organizations.Organization

    many_to_many :organizations, QuestApiV21.Organizations.Organization,
      join_through: "hosts_organizations"

    timestamps()
  end

  @doc false
  def changeset(host, attrs) do
    host
    |> cast(attrs, [
      :name,
      :email,
      :hashed_password,
      :password,
      :role,
      :current_org_id,
      :reset_password_token,
      :reset_password_sent_at
    ])
    |> validate_required([:name, :email])
    |> validate_email()
    |> cast_assoc(:organizations, with: &QuestApiV21.Organizations.Organization.changeset/2)
  end

  def password_changeset(host, attrs) do
    host
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, min: 6, max: 100)
    |> validate_confirmation(:password)
    |> put_password_hash()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email()
  end

  defp maybe_validate_unique_email(changeset) do
    changeset
    |> unsafe_validate_unique(:email, QuestApiV21.Repo)
    |> unique_constraint(:email)
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, hashed_password: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
