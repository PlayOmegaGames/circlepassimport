defmodule QuestApiV21.Quests do
  @moduledoc """
  The Quests context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.OrganizationScopedQueries
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Collectors.Collector
  alias QuestApiV21.Accounts.Account
  alias QuestApiV21.Badges.Badge

  alias QuestApiV21.Repo

  @doc """
  Returns the list of quests.

  ## Examples

      iex> list_quests()
      [%Quest{}, ...]

  """
  def list_quests do
    Repo.all(Quest)
  end

  def list_public_quests do
    Repo.all(
      from q in Quest,
        where: q.public == true,
        preload: [:badges]
    )
  end

    @doc """
  Retrieves IDs of badges collected by an account for a specific quest.
  """
  def get_collected_badges_ids_for_quest(account_id, quest_id) do
    Repo.all(
      from b in Badge,
      join: a in assoc(b, :accounts),
      where: a.id == ^account_id and b.quest_id == ^quest_id,
      select: b.id
    )
  end

  # only returns the quests that are associated to that record


  @doc """

    Testing:

    alias QuestApiV21.Quests
    Quests.list_quests_by_organization_ids("8cb1399f-e077-41ff-93cd-ce7bc3a21c98")


  """

  def list_quests_by_organization_ids(organization_ids) do
    preloads = [:organization, :badges, :collectors, :accounts]
    OrganizationScopedQueries.scope_query(Quest, organization_ids, preloads)
  end


  def get_badges_for_quest(quest_id) do
    Quest
    |> Repo.get!(quest_id)
    |> Repo.preload(:badges)
    |> Map.get(:badges)
  end

  @doc """
  Gets a single quest.

  Raises `Ecto.NoResultsError` if the Quest does not exist.

  ## Examples

      iex> get_quest!(123)
      %Quest{}

      iex> get_quest!(456)
      ** (Ecto.NoResultsError)

  """
  def get_quest(id, organization_id) do
    preloads = [:organization, :badges, :collectors, :accounts]
    OrganizationScopedQueries.get_item(Quest, id, organization_id, preloads)
  end

  def get_quests_for_account(account_id) do
    case Repo.get(Account, account_id) do
      nil ->
        {:error, :not_found}
      account ->
        # Preload quests and their associated badges
        account_with_quests_and_badges = Repo.preload(account, quests: [:badges])
        {:ok, account_with_quests_and_badges.quests}
    end
  end

  def get_earned_badges_for_quest_and_account(account_id, quest_id) do
    # Attempt to retrieve the quest without raising an error if not found
    quest = Repo.get(QuestApiV21.Quests.Quest, quest_id)

    # Handle the case where the quest is not found gracefully
    if quest == nil do
      #IO.puts("Quest not found")
      {:error, "Quest not found"}
    end

    # Attempt to retrieve the account without raising an error if not found
    account = Repo.get(QuestApiV21.Accounts.Account, account_id)

    # Handle the case where the account is not found gracefully
    if account == nil do
      #IO.puts("Account not found")
      {:error, "Account not found"}
    end

    # Preload badges for the found quest and account if both exist
    quest = Repo.preload(quest, :badges)
    account = Repo.preload(account, :badges)

    # Find shared badges by comparing the preloaded badges lists
    shared_badges = Enum.filter(quest.badges, fn badge ->
      Enum.any?(account.badges, &(&1.id == badge.id))
    end)

    # Count the shared badges
    shared_badges_count = length(shared_badges)

    #IO.inspect(shared_badges_count, label: "Shared Badges Count")

    {:ok, shared_badges_count}
  end



  @doc """
  Fetches a single quest by its ID.

  ## Examples

      iex> get_quest("123")
      %Quest{}

  """
  def get_quest(id) do
    Quest
    |> Repo.get(id)
    |> Repo.preload([:organization, :badges, :collectors, :accounts])
  end

  @doc """
  Creates a quest.

  ## Examples

      iex> create_quest(%{field: value})
      {:ok, %Quest{}}

      iex> create_quest(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_quest_with_organization(quest_params, organization_id) do
    %Quest{}
    |> Quest.changeset(Map.put(quest_params, "organization_id", organization_id))
    |> maybe_add_accounts(quest_params)
    |> Repo.insert()
  end

  @doc """
  Updates a quest.

  ## Examples

      iex> update_quest(quest, %{field: new_value})
      {:ok, %Quest{}}

      iex> update_quest(quest, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_quest(%Quest{} = quest, attrs, organization_id) do
    if quest.organization_id == organization_id do
      updated_attrs = normalize_account_ids(attrs)

      quest
      |> Quest.changeset(updated_attrs)
      |> maybe_add_collectors(updated_attrs)
      |> maybe_add_accounts(updated_attrs)
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a quest.

  ## Examples

      iex> delete_quest(quest)
      {:ok, %Quest{}}

      iex> delete_quest(quest)
      {:error, %Ecto.Changeset{}}

  """
  def delete_quest(%Quest{} = quest, organization_ids) do
    OrganizationScopedQueries.delete_item(Quest, quest.id, organization_ids)
  end

  # Compare quests between a collector and an account
  # @param collector_id The ID of the collector
  # @param account_id The ID of the account
  # @return Returns a list of common quest IDs between the collector and the account
  def compare_collector_account_quests(collector_id, account_id) do
    # Assuming you have functions to get collector and account that preload quests
    collector = Repo.get!(Collector, collector_id) |> Repo.preload(:quests)
    account = Repo.get!(Account, account_id) |> Repo.preload(:quests)

    # Extract quest IDs from both entities
    collector_quests_ids = Enum.map(collector.quests, & &1.id)
    account_quests_ids = Enum.map(account.quests, & &1.id)

    # Find common IDs
    common_quests_ids = Enum.filter(collector_quests_ids, &Enum.member?(account_quests_ids, &1))

    {:ok, common_quests_ids}
  rescue
    Ecto.NoResultsError ->
      {:error, :entity_not_found}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking quest changes.

  ## Examples

      iex> change_quest(quest)
      %Ecto.Changeset{data: %Quest{}}

  """
  def change_quest(%Quest{} = quest, attrs \\ %{}) do
    Quest.changeset(quest, attrs)
  end

  defp maybe_add_collectors(changeset, attrs) do
    case Map.get(attrs, "collector_ids") do
      nil ->
        changeset

      collector_ids ->
        collectors = Repo.all(from c in Collector, where: c.id in ^collector_ids)
        Ecto.Changeset.put_assoc(changeset, :collectors, collectors)
    end
  end

  defp maybe_add_accounts(changeset, attrs) do
    case Map.get(attrs, "account_ids") do
      nil ->
        changeset

      account_ids when is_list(account_ids) ->
        current_accounts = Ecto.assoc(changeset.data, :accounts) |> Repo.all()
        new_accounts = Repo.all(from a in Account, where: a.id in ^account_ids)
        merged_accounts = Enum.uniq(current_accounts ++ new_accounts)
        Ecto.Changeset.put_assoc(changeset, :accounts, merged_accounts)
    end
  end

  defp normalize_account_ids(attrs) do
    case Map.get(attrs, "account_ids") do
      nil -> attrs
      account_ids when is_binary(account_ids) -> Map.put(attrs, "account_ids", [account_ids])
      _ -> attrs
    end
  end
end
