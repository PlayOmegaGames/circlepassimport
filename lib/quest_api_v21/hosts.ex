defmodule QuestApiV21.Hosts do
  @moduledoc """
  The Hosts context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo

  alias QuestApiV21.Hosts.Host
  alias QuestApiV21.Hosts.HostNotifier
  alias QuestApiV21.Organizations.Organization
  require Logger

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

  def get_host_by_email(email) do
    Repo.get_by(Host, email: email)
  end

  def get_host_by_reset_password_token(token) do
    Repo.get_by(Host, reset_password_token: token)
  end

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

  def update_current_org(%Host{} = host, org_id) when is_binary(org_id) do
    if is_organization_associated_with_host?(host.id, org_id) do
      host
      |> Host.changeset(%{current_org_id: org_id})
      |> Repo.update()
    else
      {:error, :organization_not_associated}
    end
  end

  def list_hosts do
    Repo.all(Host)
  end

  def is_organization_associated_with_host?(host_id, org_id) do
    host = Repo.get!(Host, host_id) |> Repo.preload(:organizations)
    Enum.any?(host.organizations, fn org -> org.id == org_id end)
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

  def change_host_password(%Host{} = host, attrs \\ %{}) do
    Host.password_changeset(host, attrs)
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

  # Generate pwd reset token

  def generate_reset_password_token(email) do
    host = Repo.get_by(Host, email: email)

    if host do
      token = :crypto.strong_rand_bytes(32) |> Base.url_encode64() |> binary_part(0, 32)

      changeset =
        Host.changeset(host, %{
          reset_password_token: token,
          reset_password_sent_at: NaiveDateTime.utc_now()
        })

      Repo.update!(changeset)

      url = "https://questapp.io/hosts/reset_password?token=#{token}"
      HostNotifier.deliver_reset_password_instructions(host, url)
      {:ok, token}
    else
      {:error, :host_not_found}
    end
  end

  def reset_password(token, new_password) do
    host = Repo.get_by(Host, reset_password_token: token)

    if host && token_valid?(host.reset_password_sent_at) do
      changeset =
        Host.changeset(host, %{
          hashed_password: hash_password(new_password),
          reset_password_token: nil,
          reset_password_sent_at: nil
        })

      Repo.update!(changeset)
      {:ok, host}
    else
      {:error, :invalid_token}
    end
  end

  defp token_valid?(sent_at) do
    # Check if the token is still valid (e.g., within 24 hours)
    NaiveDateTime.diff(NaiveDateTime.utc_now(), sent_at) <= 86400
  end

  defp hash_password(password) do
    # Hash the password
    Bcrypt.hash_pwd_salt(password)
  end
end
