defmodule QuestApiV21.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo
  alias QuestApiV21.Badges.Badge
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Rewards
  alias QuestApiV21.Accounts.{Account, AccountToken, AccountNotifier}
  alias Bcrypt
  require Logger

  ## Database getters

  @doc """
  Gets an account by email.

  ## Examples

      iex> get_account_by_email("foo@example.com")
      %Account{}

      iex> get_account_by_email("unknown@example.com")
      nil

  """
  def get_account_by_email(email) when is_binary(email) do
    Repo.get_by(Account, email: email)
    |> Repo.preload([:quests, :badges])
  end

  def list_accounts(id) do
    Repo.get(Account, id)
  end

  @doc """
  Gets a account by email and password.

  ## Examples

      iex> get_account_by_email_and_password("foo@example.com", "correct_password")
      %Account{}

      iex> get_account_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_account_by_email_and_password(email, password)
    when is_binary(email) and is_binary(password) do
    account = Repo.get_by(Account, email: email)
    if Account.valid_password?(account, password), do: account
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id) do
    Repo.get!(Account, id)
    |> Repo.preload([:quests, :badges])
  end

  ## Account registration

  @doc """
  Registers a account.

  ## Examples

      iex> register_account(%{field: value})
      {:ok, %Account{}}

      iex> register_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_account(attrs) do
    %Account{}
    |> Account.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account_registration(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account_registration(%Account{} = account, attrs \\ %{}) do
    Account.registration_changeset(account, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the account email.

  ## Examples

      iex> change_account_email(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account_email(account, attrs \\ %{}) do
    Account.email_changeset(account, attrs, validate_email: false)
  end


  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_account_email(account, "valid password", %{email: ...})
      {:ok, %Account{}}

      iex> apply_account_email(account, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_account_email(account, password, attrs) do
    account
    |> Account.email_changeset(attrs)
    |> Account.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the account email using the given token.

  If the token matches, the account email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_account_email(account, token) do
    context = "change:#{account.email}"

    with {:ok, query} <- AccountToken.verify_change_email_token_query(token, context),
         %AccountToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(account_email_multi(account, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp account_email_multi(account, email, context) do
    changeset =
      account
      |> Account.email_changeset(%{email: email})
      |> Account.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, changeset)
    |> Ecto.Multi.delete_all(:tokens, AccountToken.by_account_and_contexts_query(account, [context]))
  end

 @doc ~S"""
  Delivers the update email instructions to the given account.

  ## Examples

      iex> deliver_account_update_email_instructions(account, current_email, &url(~p"/accounts/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_account_update_email_instructions(%Account{} = account, current_email, update_email_url_fun)
    when is_function(update_email_url_fun, 1) do
    {encoded_token, account_token} = AccountToken.build_email_token(account, "change:#{current_email}")

    Repo.insert!(account_token)
    AccountNotifier.deliver_update_email_instructions(account, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the account password.

  ## Examples

      iex> change_account_password(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account_password(account, attrs \\ %{}) do
    Account.password_changeset(account, attrs, hash_password: false)
  end

  @doc """
  Updates the account password.

  ## Examples

      iex> update_account_password(account, "valid password", %{password: ...})
      {:ok, %Account{}}

      iex> update_account_password(account, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_password(account, password, attrs) do
    changeset =
      account
      |> Account.password_changeset(attrs)
      |> Account.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, changeset)
    |> Ecto.Multi.delete_all(:tokens, AccountToken.by_account_and_contexts_query(account, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{account: account}} -> {:ok, account}
      {:error, :account, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_account_session_token(account) do
    {token, account_token} = AccountToken.build_session_token(account)
    Repo.insert!(account_token)
    token
  end

  @doc """
  Gets the account with the given signed token.
  """
  def get_account_by_session_token(token) do
    {:ok, query} = AccountToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_account_session_token(token) do
    Repo.delete_all(AccountToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given account.

  ## Examples

      iex> deliver_account_confirmation_instructions(account, &url(~p"/accounts/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_account_confirmation_instructions(confirmed_account, &url(~p"/accounts/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_account_confirmation_instructions(%Account{} = account, confirmation_url_fun)
    when is_function(confirmation_url_fun, 1) do
    if account.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, account_token} = AccountToken.build_email_token(account, "confirm")
      Repo.insert!(account_token)
      AccountNotifier.deliver_confirmation_instructions(account, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a account by the given token.

  If the token matches, the account account is marked as confirmed
  and the token is deleted.
  """
  def confirm_account(token) do
    with {:ok, query} <- AccountToken.verify_email_token_query(token, "confirm"),
         %Account{} = account <- Repo.one(query),
         {:ok, %{account: account}} <- Repo.transaction(confirm_account_multi(account)) do
      {:ok, account}
    else
      _ -> :error
    end
  end

  defp confirm_account_multi(account) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, Account.confirm_changeset(account))
    |> Ecto.Multi.delete_all(:tokens, AccountToken.by_account_and_contexts_query(account, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given account.

  ## Examples

      iex> deliver_account_reset_password_instructions(account, &url(~p"/accounts/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_account_reset_password_instructions(%Account{} = account, reset_password_url_fun)
    when is_function(reset_password_url_fun, 1) do
    {encoded_token, account_token} = AccountToken.build_email_token(account, "reset_password")
    Repo.insert!(account_token)
    AccountNotifier.deliver_reset_password_instructions(account, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the account by reset password token.

  ## Examples

      iex> get_account_by_reset_password_token("validtoken")
      %Account{}

      iex> get_account_by_reset_password_token("invalidtoken")
      nil

  """
  def get_account_by_reset_password_token(token) do
    with {:ok, query} <- AccountToken.verify_email_token_query(token, "reset_password"),
         %Account{} = account <- Repo.one(query) do
      account
    else
      _ -> nil
    end
  end

  @doc """
  Resets the account password.

  ## Examples

      iex> reset_account_password(account, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Account{}}

      iex> reset_account_password(account, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_account_password(account, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, Account.password_changeset(account, attrs))
    |> Ecto.Multi.delete_all(:tokens, AccountToken.by_account_and_contexts_query(account, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{account: account}} -> {:ok, account}
      {:error, :account, changeset, _} -> {:error, changeset}
    end
  end


  #================= OLD CONTEXT ===============

  @doc """
  Creates an account.

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
        Logger.debug(
          "No existing account found for email: #{email}, proceeding to create new account"
        )

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

  # for cases where password is not provided
  defp put_password_hash(attrs), do: attrs

  @doc """
  Finds or creates a account based on email. If a account doesn't exist, creates a new account with the provided email and name.

  ## Examples

      iex> find_or_create_account("new@example.com", "New Account")
      {:ok, %Account{}}

      iex> find_or_create_user("existing@example.com", "Existing Account")
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
      # Indicate that this account does not use a password
      is_passwordless: true
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
    # Pass the struct and attrs to changeset/2
    |> Account.changeset(attrs)
    |> maybe_add_badges(attrs)
    |> maybe_add_quests(attrs)
    |> Repo.update()
  end

  @doc """
  Handles the OAuth login or account creation flow.

  If the email exists, it returns the existing account.
  If not, it creates a new account with the given email and name.

  ## Examples

      iex> handle_oauth_login("new@example.com", "New Account")
      {:ok, %Account{}, :new}

      iex> handle_oauth_login("existing@example.com", "Existing Account")
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

  def find_account_by_id(id) do
    Repo.get_by(Account, id: id)
  end

  def authenticate_user_by_password(_email, id, current_password) do
    IO.inspect("Authenticate User Function")

    case find_account_by_id(id) do
      nil ->
        {:error, :not_found}

      account ->
        if Bcrypt.verify_pass(current_password, account.hashed_password) do
          {:ok, account}
        else
          {:error, :unauthorized}
        end
    end
  end

  @doc """
  Finds an account by a unique identifier.

  ## Examples

      iex> get_user_by_identifier("account@example.com")
      %Account{}

      iex> get_user_by_identifier("nonexistent@example.com")
      nil
  """
  # For the token exchange how to identify the account
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

  # In QuestApiV21.Accounts context

  def add_badges_to_account(account_id, badge_ids) when is_list(badge_ids) do
    account = Repo.get!(Account, account_id) |> Repo.preload(:badges)

    # Calculate which badge IDs are new to avoid duplications
    existing_badge_ids = Enum.map(account.badges, & &1.id)
    new_badge_ids = badge_ids -- existing_badge_ids

    if Enum.empty?(new_badge_ids) do
      # No new badges to add
      {:ok, []}
    else
      new_badges = Repo.all(from b in Badge, where: b.id in ^new_badge_ids)

      # Ensure there are badges to add; otherwise, it might indicate invalid badge IDs were provided
      if Enum.empty?(new_badges) do
        {:error, :no_badges_found}
      else
        updated_badges = account.badges ++ new_badges

        case Repo.update(
               Ecto.Changeset.change(account)
               |> Ecto.Changeset.put_assoc(:badges, updated_badges)
             ) do
          {:ok, _account} -> {:ok, new_badges}
          {:error, changeset} -> {:error, changeset}
        end
      end
    end
  rescue
    # Handle cases where the account doesn't exist
    Ecto.NoResultsError -> {:error, :account_not_found}
  end

  def authenticate_user(email, password) do
    case find_account_by_email(email) do
      nil ->
        {:error, :not_found}

      account ->
        if Bcrypt.verify_pass(password, account.hashed_password) do
          {:ok, account}
        else
          {:error, :unauthorized}
        end
    end
  end

  def authenticate_user_by_id(_email, id, password) do
    IO.inspect("Authenticate User Function")

    case find_account_by_id(id) do
      nil ->
        {:error, :not_found}

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
        #Logger.debug("No badge IDs provided in attributes")
        changeset

      badge_ids ->
        #Logger.debug("Badge IDs provided: #{inspect(badge_ids)}")
        badges = Repo.all(from b in Badge, where: b.id in ^badge_ids)
        #Logger.debug("Badges found: #{inspect(badges)}")

        current_stats = changeset.data.badges_stats
        #Logger.debug("Current badge stats: #{inspect(current_stats)}")
        badges_count = length(badge_ids)

        updated_changeset = Ecto.Changeset.put_assoc(changeset, :badges, badges)

        updated_changeset_with_stats =
          Ecto.Changeset.put_change(
            updated_changeset,
            :badges_stats,
            current_stats + badges_count
          )

        #Logger.debug("Updated changeset: #{inspect(updated_changeset_with_stats)}")
        updated_changeset_with_stats
    end
  end

  defp maybe_add_quests(changeset, attrs) do
    case Map.get(attrs, "quest_ids") do
      nil ->
        changeset

      quest_ids when is_list(quest_ids) ->
        current_quests = Ecto.assoc(changeset.data, :quests) |> Repo.all()
        new_quests = Repo.all(from q in Quest, where: q.id in ^quest_ids)
        merged_quests = Enum.uniq(current_quests ++ new_quests)
        Ecto.Changeset.put_assoc(changeset, :quests, merged_quests)
    end
  end

  # Function to update the selected_quest field for an account
  def update_selected_quest_for_user(account_id, quest_id) do
    account = Repo.get!(Account, account_id)
    changeset = Ecto.Changeset.change(account, %{selected_quest_id: quest_id})
    Repo.update(changeset)
  end

  # for the show collector function
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

  @doc """

  the function that handles adding a badge to a user

  Example

  alias QuestApiV21.Repo
  alias QuestApiV21.Accounts.Account
  alias QuestApiV21.Accounts
  alias QuestApiV21.Badges.Badge

  badge = Repo.get(Badge, "9b7015b1-c4bb-4323-b7d2-98f881036553")
  {:ok, message, updated_account} = Accounts.add_badge_to_user("d26326d1-be5b-4a24-a82e-57d855f95b89", badge)
  """
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
        IO.inspect("Completed Quest")
        updated_account =
          Ecto.Changeset.change(updated_account,
            rewards_stats: updated_account.rewards_stats + 1
          )

        # Attempt to create a reward record
        reward_attrs = %{
          quest_id: badge.quest_id,
          account_id: user_id,
          # Include any other necessary attributes here
        }
        case Rewards.create_reward(reward_attrs) do
          {:ok, _reward} ->
            IO.inspect("Created reward")
            # Proceed with updating the account to reflect the reward addition
            case Repo.update(updated_account) do
              {:ok, updated_account} ->
                {:ok, "Badge and reward added to the account", updated_account}

              {:error, reason} ->
                {:error, reason}
            end
          {:error, reason} ->
            {:error, reason}
        end
      else
        {:ok, "Badge added to the account", updated_account}
      end

      end
    end
  end

  # This function determines if the given account has any active (i.e., incomplete) quests.
  def has_active_quests?(account_id) do
    # Fetch the account by its ID, raising an error if it's not found.
    account = Repo.get!(Account, account_id)

    # Preload the associated badges and quests for the account to reduce database queries.
    user_with_badges_and_quests = Repo.preload(account, [:badges, :quests])

    # Iterate over the quests associated with the user to check for any that are not completed.
    Enum.any?(user_with_badges_and_quests.quests, fn quest ->
      # If any quest is found to be incomplete (by calling `quest_completed?`), return true.
      not quest_completed?(user_with_badges_and_quests, quest.id)
    end)
  end

  # A helper function to determine if a specific quest for an account is completed by checking associated badges.
  defp quest_completed?(account, quest_id) do
    # Retrieve all badges associated with the quest_id from the database.
    quest_badges = Repo.all(from b in Badge, where: b.quest_id == ^quest_id, select: b.id)

    # For the quest to be considered completed, the account must have all badges associated with the quest.
    Enum.all?(quest_badges, fn badge_id ->
      # Check if the account possesses each badge required for the quest's completion.
      Enum.any?(account.badges, fn b -> b.id == badge_id end)
    end)
  end

end
