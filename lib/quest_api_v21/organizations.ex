defmodule QuestApiV21.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo

  alias QuestApiV21.Organizations.Organization
  alias QuestApiV21.Hosts.Host

  @doc """
  Returns the list of organizations.

  ## Examples

      iex> list_organizations()
      [%Organization{}, ...]

  """
  def list_organizations do
    Repo.all(Organization)
  end

  @doc """
  Gets a single organization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

      iex> get_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(id), do: Repo.get!(Organization, id)

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(attrs \\ %{}, host_id) do
    host = Repo.get!(Host, host_id)

    organization_changeset =
      %Organization{}
      |> Organization.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:hosts, [host])

    #retrieves the organization id of the newly created org
    case Repo.insert(organization_changeset) do
      {:ok, organization} ->
        updated_organization_ids = fetch_updated_organization_ids_for_host(host)
        new_jwt = generate_new_jwt_for_host(host, updated_organization_ids)
        {:ok, organization, new_jwt}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> maybe_add_hosts(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{data: %Organization{}}

  """
  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
  end

  defp maybe_add_hosts(changeset, attrs) do
    case Map.get(attrs, "host_ids") do
      nil -> changeset
      host_ids ->
        hosts = Repo.all(from h in Host, where: h.id in ^host_ids)
        Ecto.Changeset.put_assoc(changeset, :hosts, hosts)
    end
  end

  defp fetch_updated_organization_ids_for_host(host) do
    Repo.all(
      from(o in Organization,
        join: h in assoc(o, :hosts),
        where: h.id == ^host.id,
        select: o.id)
    )
  end


  defp generate_new_jwt_for_host(host, organization_ids) do
    # Assuming HostGuardian.encode_and_sign can accept additional claims
    claims = %{"organization_ids" => organization_ids}
    {:ok, jwt, _full_claims} = QuestApiV21.HostGuardian.encode_and_sign(host, claims)
    jwt
  end

end
