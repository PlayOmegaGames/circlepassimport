defmodule QuestApiV21.Badges do
  @moduledoc """
  The Badges context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.OrganizationScopedQueries
  alias QuestApiV21.Repo
  alias QuestApiV21.Accounts.Account
  alias QuestApiV21.Collector
  alias QuestApiV21.Quests
  alias QuestApiV21.Badges.Badge
  require Logger
  alias QuestApiV21.SubscriptionChecker

  @doc """
  Returns the list of badge.

  ## Examples

      iex> list_badge()
      [%Badge{}, ...]

  """
  def list_badge do
    Repo.all(Badge)
  end

  @doc """
  Returns a list of badges filtered by the given list of IDs.

  ## Examples

      iex> list_badges_by_ids([123, 456])
      [%Badge{id: 123}, %Badge{id: 456}]
  """
  def list_badges_by_ids(badge_ids) do
    from(b in Badge, where: b.id in ^badge_ids) |> Repo.all()
  end

  @doc """
  Gets a single badge.

  Raises `Ecto.NoResultsError` if the Collection  point does not exist.

  ## Examples

      iex> get_badge!(123)
      %Badge{}

      iex> get_badge!(456)
      ** (Ecto.NoResultsError)

    alias QuestApiV21.Badges


  """
  def get_badge!(id), do: Repo.get!(Badge, id)

  @doc """
  Gets a single badge and preloads its associated quest.

  Raises `Ecto.NoResultsError` if the badge does not exist.

  ## Examples

      iex> get_badge_with_quest!(123)
      %Badge{}

      iex> get_badge_with_quest!(456)
      ** (Ecto.NoResultsError)
  """
  def get_badge_with_quest!(badge_id) do
    Repo.get!(Badge, badge_id)
    |> Repo.preload(:quest)
  end

  def list_badges_by_organization_id(organization_id) do
    preloads = [:organization, :accounts]
    OrganizationScopedQueries.scope_query(Badge, organization_id, preloads)
  end

  @doc """
  Fetches all badges associated with a given account ID.

  ## Examples

      iex> get_badges_for_account("account_id")
      {:ok, [%Badge{}, ...]}

      iex> get_badges_for_account("nonexistent_account_id")
      {:error, :not_found}
  """
  def get_badges_for_account(account_id) do
    case Repo.get(Account, account_id) do
      nil ->
        {:error, :not_found}

      account ->
        # Preload badges for the found account
        account_with_badges = Repo.preload(account, :badges)
        {:ok, account_with_badges.badges}
    end
  end

  @doc """
  Creates a badge.

  ## Examples

      iex> create_badge(%{field: value})
      {:ok, %Badge{}}

      iex> create_badge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @badge_tier_limits %{
    "tier_1" => 50,
    "tier_2" => 100
  }


  def create_badge_with_organization(badge_params, organization_id) do
    case SubscriptionChecker.can_create_record?(organization_id, Badge, @badge_tier_limits) do
      :ok ->
        changeset =
          %Badge{}
          |> Badge.changeset(Map.put(badge_params, "organization_id", organization_id))
          |> maybe_add_accounts(badge_params)

        case Repo.insert(changeset) do
          {:ok, badge} ->
            badge |> update_quest_numbers()
            {:ok, badge}

          {:error, changeset} ->
            {:error, changeset}
        end

      {:error, reason} ->
        Logger.error("Badge creation failed due to: #{inspect(reason)}")
        handle_error(reason)
    end
  end

  defp handle_error(reason) do
    case reason do
      :organization_not_found -> {:error, :organization_not_found}
      :no_subscription_tier -> {:error, :no_subscription_tier}
      :upgrade_subscription -> {:error, :upgrade_subscription}
    end
  end

  @doc """
  Updates a badge.

  ## Examples

      iex> update_badge(badge, %{field: new_value})
      {:ok, %Badge{}}

      iex> update_badge(badge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_badge(%Badge{} = badge, attrs, organization_ids) do
    if badge.organization_id == organization_ids do
      # Preload accounts before updating
      badge = Repo.preload(badge, :accounts)

      badge
      |> Badge.changeset(attrs)
      |> maybe_add_accounts(attrs)
      |> Repo.update()
      # Only updates the completion score if the record is successfully updated
      |> case do
        {:ok, badge} ->
          badge |> update_quest_numbers()
          {:ok, badge}

        error ->
          error
      end
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a badge.

  ## Examples

      iex> delete_badge(badge)
      {:ok, %Badge{}}

      iex> delete_badge(badge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_badge(%Badge{} = badge) do
    Repo.delete(badge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking badge changes.

  ## Examples

      iex> change_badge(badge)
      %Ecto.Changeset{data: %Badge{}}

  """
  def change_badge(%Badge{} = badge, attrs \\ %{}) do
    Badge.changeset(badge, attrs)
  end

  # update the quest completion score when a badge is associated with a quest
  defp update_quest_numbers(%Badge{
         quest_id: quest_id,
         badge_points: points,
         organization_id: organization_id
       }) do
    if quest_id do
      quest = Quests.get_quest(quest_id, organization_id)
      # if it doesnt default to 0 we get an error adding to nil
      score = quest.completion_score || 0

      badge_count = quest.badge_count
      # increase the points by the badge points of the badge
      new_score = score + points
      new_count = badge_count + 1

      Quests.update_quest(
        quest,
        %{completion_score: new_score, badge_count: new_count},
        organization_id
      )
    else
      :noop
    end
  end

  @doc """

    Compares badges in the quest vs badges the user has collected

  """

  # Compares badges associated with a collector to those associated with the collector's quests.
  # @param collector_id The ID of the collector whose badges are to be compared.
  # @return Returns {:ok, common_badges} if common badges are found, or {:error, :collector_not_found} if the collector does not exist.
  def compare_collector_badges_to_quest_badges(collector_id) do
    # Fetch the collector from the database and preload its badges and quests' badges.
    # This ensures we have all necessary data loaded for comparison.
    collector = Repo.get!(Collector, collector_id) |> Repo.preload(badges: [], quests: :badges)

    # Extract the IDs of all badges directly associated with the collector.
    # This step prepares the list of badge IDs for the comparison.
    collector_badges = Enum.map(collector.badges, fn badge -> badge.id end)

    # Extract the IDs of all badges associated with the collector's quests.
    # This involves flattening the list since each quest may have multiple badges.
    quest_badges =
      Enum.flat_map(collector.quests, fn quest ->
        Enum.map(quest.badges, fn badge -> badge.id end)
      end)

    # Find the common badge IDs between the collector's badges and the quests' badges.
    # This comparison identifies which badges are shared across the collector's direct badges and their quests.
    common_badges =
      Enum.filter(quest_badges, fn badge_id -> Enum.member?(collector_badges, badge_id) end)

    # Return the list of common badge IDs wrapped in an {:ok, _} tuple to indicate success.
    {:ok, common_badges}
  rescue
    # Catch the case where the collector does not exist (e.g., an invalid collector_id was provided).
    # In such cases, return an error tuple indicating the collector was not found.
    Ecto.NoResultsError ->
      {:error, :collector_not_found}
  end

  defp maybe_add_accounts(changeset, attrs) do
    case Map.get(attrs, "accounts_id") do
      nil ->
        changeset

      account_ids ->
        accounts = Repo.all(from a in Account, where: a.id in ^account_ids)
        Ecto.Changeset.put_assoc(changeset, :accounts, accounts)
    end
  end
end
