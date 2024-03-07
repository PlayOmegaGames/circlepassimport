defmodule QuestApiV21.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.OrganizationScopedQueries
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

  def list_organizations_by_host_id(host_id) do
    preloads = [:hosts]
    OrganizationScopedQueries.org_scope_query(Organization, host_id, preloads)
  end
    @doc """
  Associates a host found by email with the provided organization ID.

  ## Parameters

  - email: The email of the host to find.
  - organization_id: The ID of the organization to associate with the host.

  ## Examples

      iex> associate_host_with_organization("host@example.com", "org_id")
      {:ok, %Organization{}}

      iex> associate_host_with_organization("nonexistent@example.com", "org_id")
      {:error, :host_not_found}

      iex> associate_host_with_organization("host@example.com", "nonexistent_org_id")
      {:error, :organization_not_found}

      alias QuestApiV21.Organizations
      Organizations.associate_host_with_organization("jay@yptocnge.consulting","8cb1399f-e077-41ff-93cd-ce7bc3a21c98")
  """
  def associate_host_with_organization(email, organization_id) do
    case QuestApiV21.Hosts.get_host_by_email(email) do
      nil ->
        {:error, :host_not_found}

      %Host{} = host ->
        # Preload the hosts association on the organization before attempting to update it.
        organization = Repo.get(Organization, organization_id) |> Repo.preload(:hosts)

        if organization do
          update_organization_hosts(organization, host)
        else
          {:error, :organization_not_found}
        end
    end
  end

  defp update_organization_hosts(%Organization{} = organization, %Host{} = host) do
    updated_hosts = [host | organization.hosts]

    changeset =
      organization
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:hosts, updated_hosts)

    Repo.update(changeset)
  end

  @doc"""

    alias QuestApiV21.Organizations
    Organizations.list_organizations_by_organization_id("8cb1399f-e077-41ff-93cd-ce7bc3a21c98")

  nowork
  """
  def list_organizations_by_organization_id(organization_id) do
    preloads = [:hosts]
    OrganizationScopedQueries.scope_query(Organization, organization_id, preloads)
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

    case Repo.insert(organization_changeset) do
      {:ok, organization} ->
        # Now, update the host's current_org_id
        case QuestApiV21.Hosts.update_current_org(host, organization.id) do
          {:ok, _updated_host} ->
            new_jwt = generate_new_jwt_for_host(host)
            {:ok, organization, new_jwt}

          {:error, _reason} ->
            # Handle the error appropriately
            {:error, :failed_to_update_host}
        end

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
      nil ->
        changeset

      host_ids ->
        hosts = Repo.all(from h in Host, where: h.id in ^host_ids)
        Ecto.Changeset.put_assoc(changeset, :hosts, hosts)
    end
  end

  defp generate_new_jwt_for_host(%Host{} = host) do
    # Assuming HostGuardian.encode_and_sign can accept additional claims
    # Directly use the host's current_org_id for the claim
    claims = %{"organization_id" => host.current_org_id}
    {:ok, jwt, _full_claims} = QuestApiV21.HostGuardian.encode_and_sign(host, claims)
    jwt
  end
end
