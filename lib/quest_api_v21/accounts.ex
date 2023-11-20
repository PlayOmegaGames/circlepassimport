defmodule QuestApiV21.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo
  alias QuestApiV21.Badges.Badge

  alias QuestApiV21.Accounts.Account
  alias Bcrypt

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    email = Map.get(attrs, "email")

    case find_account_by_email(email) do
      nil ->
        updated_attrs =
          if Map.get(attrs, "is_passwordless", false) do
            # Skip password hashing for passwordless accounts
            attrs
          else
            put_password_hash(attrs)
          end

        %Account{}
        |> Account.changeset(updated_attrs)
        |> maybe_add_badges(attrs)
        |> Repo.insert()

      existing_account ->
        {:error, "An account with this email already exists", existing_account}
    end
  end

  defp put_password_hash(%{"password" => password} = attrs) do
    Map.put(attrs, "hashed_password", Bcrypt.hash_pwd_salt(password))
  end
  defp put_password_hash(attrs), do: attrs  # for cases where password is not provided


  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
   # Existing clauses
   def update_account(%Account{} = account, attrs) do
    account = Repo.preload(account, :badges)
    account
    |> Account.changeset(attrs)  # Pass the struct and attrs to changeset/2
    |> maybe_add_badges(attrs)
    |> Repo.update()
  end


  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Finds an account by email.

  ## Examples

      iex> find_account_by_email("test@example.com")
      %Account{}

      iex> find_account_by_email("nonexistent@example.com")
      nil
  """
  def find_account_by_email(email) do
    Repo.get_by(Account, email: email)
  end

    @doc """
  Finds an account by a unique identifier.

  ## Examples

      iex> get_user_by_identifier("user@example.com")
      %Account{}

      iex> get_user_by_identifier("nonexistent@example.com")
      nil
  """
  #For the token exchange how to identify the account
  def get_user_by_identifier(identifier) do
    Repo.get_by(Account, email: identifier)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end

  defp maybe_add_badges(changeset, attrs) do
    case Map.get(attrs, "badge_ids") do
      nil -> changeset
      badge_ids ->
        badges = Repo.all(from c in Badge, where: c.id in ^badge_ids)
        Ecto.Changeset.put_assoc(changeset, :badges, badges)
    end
  end

end
