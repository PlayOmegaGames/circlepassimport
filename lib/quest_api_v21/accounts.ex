defmodule QuestApiV21.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo
  alias QuestApiV21.Badges.Badge
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Accounts.Account
  alias Bcrypt
  require Logger

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def list_accounts(id) do
    Repo.get(Account, id)
  end

  def get_account!(id) do
    Repo.get!(Account, id)
    |> Repo.preload([:quests, :badges])
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
def create_account(attrs \\ %{}) do
  email =
    case Map.fetch(attrs, "email") do
      {:ok, email} -> email
      :error -> Map.get(attrs, :email)
    end

    Logger.debug("create_account called with attrs: #{inspect(attrs)}")

  case find_account_by_email(email) do
    nil ->
      Logger.debug("No existing account found for email: #{email}, proceeding to create new account")
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
        |> maybe_add_quests(attrs)
        |> Repo.insert()

        _existing_account ->
          {:error, :email_taken}
      end
  end

  defp put_password_hash(%{"password" => password} = attrs) do
    Map.put(attrs, "hashed_password", Bcrypt.hash_pwd_salt(password))
  end
  defp put_password_hash(attrs), do: attrs  # for cases where password is not provided

  @doc """
  Finds or creates a user based on email. If a user doesn't exist, creates a new user with the provided email and name.

  ## Examples

      iex> find_or_create_user("new@example.com", "New User")
      {:ok, %Account{}}

      iex> find_or_create_user("existing@example.com", "Existing User")
      {:ok, %Account{}}

  """
  def find_or_create_user(email, name) do
    case find_account_by_email(email) do
      nil ->
        create_user_for_google_sso(email, name)

      account ->
        {:ok, account}
    end
  end

  defp create_user_for_google_sso(email, name) do
    user_attrs = %{
      email: email,
      name: name,
      is_passwordless: true # Indicate that this account does not use a password
    }

    create_account(user_attrs)
  end

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
    |> maybe_add_quests(attrs)
    |> Repo.update()
  end

    @doc """
  Handles the OAuth login or account creation flow.

  If the email exists, it returns the existing account.
  If not, it creates a new account with the given email and name.

  ## Examples

      iex> handle_oauth_login("new@example.com", "New User")
      {:ok, %Account{}, :new}

      iex> handle_oauth_login("existing@example.com", "Existing User")
      {:ok, %Account{}, :existing}
  """
  def handle_oauth_login(email, name) do
    Logger.debug("handle_oauth_login called with email: #{email} and name: #{name}")
    case find_account_by_email(email) do
      nil ->
        create_oauth_account(email, name)
        |> case do
          {:ok, account} -> {:ok, account, :new}
          {:error, reason} -> {:error, reason}
        end

      account ->
        {:ok, account, :existing}
    end
  end

  def create_oauth_account(email, name) do
    Logger.debug("create_oauth_account called with email: #{email}")
    user_attrs = %{
      email: email,
      name: name,
      is_passwordless: true
    }
    Logger.debug("user_attrs for account creation: #{inspect(user_attrs)}")
    create_account(user_attrs)
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

  def authenticate_user(email, password) do
    case find_account_by_email(email) do
      nil -> {:error, :not_found}
      account ->
        if Bcrypt.verify_pass(password, account.hashed_password) do
          {:ok, account}
        else
          {:error, :unauthorized}
        end
    end
  end


  defp maybe_add_badges(changeset, attrs) do
    case Map.get(attrs, "badge_ids") do
      nil ->
        Logger.debug("No badge IDs provided in attributes")
        changeset

      badge_ids ->
        Logger.debug("Badge IDs provided: #{inspect(badge_ids)}")
        badges = Repo.all(from b in Badge, where: b.id in ^badge_ids)
        Logger.debug("Badges found: #{inspect(badges)}")

        current_stats = changeset.data.badges_stats
        Logger.debug("Current badge stats: #{inspect(current_stats)}")
        badges_count = length(badge_ids)

        updated_changeset = Ecto.Changeset.put_assoc(changeset, :badges, badges)
        updated_changeset_with_stats = Ecto.Changeset.put_change(updated_changeset, :badges_stats, current_stats + badges_count)

        Logger.debug("Updated changeset: #{inspect(updated_changeset_with_stats)}")
        updated_changeset_with_stats
    end
  end



  defp maybe_add_quests(changeset, attrs) do
    case Map.get(attrs, "quest_ids") do
      nil -> changeset
      quest_ids when is_list(quest_ids) ->
        current_quests = Ecto.assoc(changeset.data, :quests) |> Repo.all()
        new_quests = Repo.all(from q in Quest, where: q.id in ^quest_ids)
        merged_quests = Enum.uniq(current_quests ++ new_quests)
        Ecto.Changeset.put_assoc(changeset, :quests, merged_quests)
    end
  end

  #for the show collector function
  def add_quest_to_user(user_id, quest) do
    account = Repo.get!(Account, user_id) |> Repo.preload(:quests)

    if Enum.any?(account.quests, fn q -> q.id == quest.id end) do
      Logger.info("Quest ID: #{quest.id} already associated with Account ID: #{account.id}")
      {:ok, "Quest already associated with the account", account}
    else
      Logger.info("Adding Quest ID: #{quest.id} to Account ID: #{account.id}")
      updated_quests = [quest | account.quests]
      Ecto.Changeset.change(account)
      |> Ecto.Changeset.put_assoc(:quests, updated_quests)
      |> Ecto.Changeset.put_change(:quests_stats, account.quests_stats + 1)
      |> Repo.update()
      |> case do
        {:ok, updated_account} -> {:ok, "Quest added to the account", updated_account}
        {:error, reason} -> {:error, reason}
      end
    end
  end


  def add_badge_to_user(user_id, badge) do
    account = Repo.get!(Account, user_id) |> Repo.preload([:badges])

    if Enum.any?(account.badges, fn b -> b.id == badge.id end) do
      Logger.info("Badge ID: #{badge.id} already associated with Account ID: #{account.id}")
      {:ok, "Badge already associated with the account", account}
    else
      Logger.info("Adding Badge ID: #{badge.id} to Account ID: #{account.id}")
      updated_badges = [badge | account.badges]

      changeset =
        account
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:badges, updated_badges)
        |> Ecto.Changeset.put_change(:badges_stats, account.badges_stats + 1)

      with {:ok, updated_account} <- Repo.update(changeset) do
        if quest_completed?(updated_account, badge.quest_id) do
          updated_account = Ecto.Changeset.change(updated_account, rewards_stats: updated_account.rewards_stats + 1)
          case Repo.update(updated_account) do
            {:ok, updated_account} -> {:ok, "Badge and reward added to the account", updated_account}
            {:error, reason} -> {:error, reason}
          end
        else
          {:ok, "Badge added to the account", updated_account}
        end
      end
    end
  end

  defp quest_completed?(account, quest_id) do
    quest_badges = Repo.all(from b in Badge, where: b.quest_id == ^quest_id, select: b.id)
    Enum.all?(quest_badges, fn badge_id ->
      Enum.any?(account.badges, fn b -> b.id == badge_id end)
    end)
  end



end
