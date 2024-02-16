defmodule QuestApiV21.Hosts do
  @moduledoc """
  The Hosts context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo

  alias QuestApiV21.Hosts.Host
  alias QuestApiV21.Organizations.Organization

  @doc """
  Returns the list of hosts.

  ## Examples

      iex> list_hosts()
      [%Host{}, ...]

  """
  def list_hosts(id) do
    Repo.get(Host, id)
  end

  @doc """
  Gets a single host.

  Raises `Ecto.NoResultsError` if the Host does not exist.

  ## Examples

      iex> get_host!(123)
      %Host{}

      iex> get_host!(456)
      ** (Ecto.NoResultsError)

  """
  def get_host!(id), do: Repo.get!(Host, id)

  @doc """
  Creates a host.

  ## Examples

      iex> create_host(%{field: value})
      {:ok, %Host{}}

      iex> create_host(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_host(attrs \\ %{}) do
    case get_host_by_email(attrs["email"]) do
      nil ->
        updated_attrs = attrs |> put_password_hash()

        %Host{}
        |> Host.changeset(updated_attrs)
        |> maybe_add_organizations(attrs)
        |> Repo.insert()

      _existing_host ->
        {:error, "A host with this email already exists"}
    end
  end

  defp get_host_by_email(email) when is_binary(email) do
    Repo.get_by(Host, email: email)
  end

  defp put_password_hash(%{"password" => password} = attrs) do
    Map.put(attrs, "hashed_password", Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(attrs), do: attrs

  @doc """
  Updates a host.

  ## Examples

      iex> update_host(host, %{field: new_value})
      {:ok, %Host{}}

      iex> update_host(host, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_host(%Host{} = host, attrs) do
    host
    |> Host.changeset(attrs)
    |> maybe_add_organizations(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a host.

  ## Examples

      iex> delete_host(host)
      {:ok, %Host{}}

      iex> delete_host(host)
      {:error, %Ecto.Changeset{}}

  """
  def delete_host(%Host{} = host) do
    Repo.delete(host)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking host changes.

  ## Examples

      iex> change_host(host)
      %Ecto.Changeset{data: %Host{}}

  """
  def change_host(%Host{} = host, attrs \\ %{}) do
    Host.changeset(host, attrs)
  end

  defp maybe_add_organizations(changeset, attrs) do
    case Map.get(attrs, "organization_ids") do
      nil ->
        changeset

      organization_ids ->
        organizations = Repo.all(from b in Organization, where: b.id in ^organization_ids)
        Ecto.Changeset.put_assoc(changeset, :organizations, organizations)
    end
  end
end
