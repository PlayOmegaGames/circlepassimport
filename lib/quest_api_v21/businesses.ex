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
  Gets a single orgaization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_orgaization!(123)
      %Organization{}

      iex> get_orgaization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_orgaization!(id), do: Repo.get!(Organization, id)

  @doc """
  Creates a orgaization.

  ## Examples

      iex> create_orgaization(%{field: value})
      {:ok, %Organization{}}

      iex> create_orgaization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_orgaization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> maybe_add_hosts(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a orgaization.

  ## Examples

      iex> update_orgaization(orgaization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_orgaization(orgaization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_orgaization(%Organization{} = orgaization, attrs) do
    orgaization
    |> Organization.changeset(attrs)
    |> maybe_add_hosts(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a orgaization.

  ## Examples

      iex> delete_orgaization(orgaization)
      {:ok, %Organization{}}

      iex> delete_orgaization(orgaization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_orgaization(%Organization{} = orgaization) do
    Repo.delete(orgaization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking orgaization changes.

  ## Examples

      iex> change_orgaization(orgaization)
      %Ecto.Changeset{data: %Organization{}}

  """
  def change_orgaization(%Organization{} = orgaization, attrs \\ %{}) do
    Organization.changeset(orgaization, attrs)
  end

  defp maybe_add_hosts(changeset, attrs) do
    case Map.get(attrs, "host_ids") do
      nil -> changeset
      host_ids ->
        hosts = Repo.all(from h in Host, where: h.id in ^host_ids)
        Ecto.Changeset.put_assoc(changeset, :hosts, hosts)
    end
  end
end
