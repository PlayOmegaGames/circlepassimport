defmodule QuestApiV21.Collectors do
  @moduledoc """
  The Collectors context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo
  alias QuestApiV21.Collectors.Collector
  alias QuestApiV21.OrganizationScopedQueries
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.SubscriptionChecker
  require Logger

  @doc """
  Returns the list of collectors.

  ## Examples

      iex> list_collectors()
      [%Collector{}, ...]

  """
  def list_collectors do
    Repo.all(Collector)
  end

  def list_collectors_by_organization_ids(organization_ids) do
    preloads = [:quests, :badges]
    OrganizationScopedQueries.scope_query(Collector, organization_ids, preloads)
  end

  @doc """
  Gets a single collector.

  Raises `Ecto.NoResultsError` if the Collector does not exist.

  ## Examples

      iex> get_collector!(123)
      %Collector{}

      iex> get_collector!(456)
      ** (Ecto.NoResultsError)

  """

  def get_quest_name(quest_id) do
    QuestApiV21.Repo.get(QuestApiV21.Quests.Quest, quest_id)
    |> case do
      nil -> nil
      quest -> quest.name
    end
  end

  @doc """
  Gets a single collector by ID, scoped by organization IDs.

  ## Parameters

    - id: The ID of the collector to fetch.
    - organization_ids: A list of organization IDs to scope the query.

  ## Returns

    - A collector struct if found within the scoped organizations, otherwise nil.

  """
  def get_collector(id, organization_ids) do
    preloads = [:quests, :badges]

    OrganizationScopedQueries.get_item(Collector, id, organization_ids, preloads)
  end

  @doc """
  Gets a single collector without raising an exception.

  Returns nil if the Collector does not exist.

  ## Examples

      iex> get_collector(123)
      %Collector{}

      iex> get_collector(456)
      nil
  """
  def get_collector(id) do
    Repo.get(Collector, id)
    |> case do
      nil ->
        nil

      collector ->
        Repo.preload(collector,
          quests: [badges: :accounts],
          badges: :accounts
        )
    end
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
  def get_quest!(id) do
    Repo.get!(Quest, id)
  end

  @doc """
  Creates a collector.

  ## Examples

      iex> create_collector(%{field: value})
      {:ok, %Collector{}}

      iex> create_collector(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_collector(attrs \\ %{}) do
    %Collector{}
    |> Collector.changeset(attrs)
    |> maybe_add_quests(attrs)
    |> Repo.insert()
  end

  @collector_tier_limits %{
    "tier_1" => 50,
    "tier_2" => 100
  }

  def create_collector_with_organization(collector_params, organization_id) do
    case SubscriptionChecker.can_create_record?(
           organization_id,
           Collector,
           @collector_tier_limits
         ) do
      :ok ->
        changeset =
          %Collector{}
          |> Collector.changeset(Map.put(collector_params, "organization_id", organization_id))
          |> maybe_add_quests(collector_params)

        case Repo.insert(changeset) do
          {:ok, collector} -> {:ok, collector}
          {:error, changeset} -> {:error, changeset}
        end

      {:error, reason} ->
        Logger.error("Collector creation failed due to: #{inspect(reason)}")
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
  Updates a collector.

  ## Examples

      iex> update_collector(collector, %{field: new_value})
      {:ok, %Collector{}}

      iex> update_collector(collector, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_collector(%Collector{} = collector, attrs, organization_ids) do
    if collector.organization_id == organization_ids do
      collector
      |> Collector.changeset(attrs)
      |> maybe_add_quests(attrs)
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a collector.

  ## Examples

      iex> delete_collector(collector)
      {:ok, %Collector{}}

      iex> delete_collector(collector)
      {:error, %Ecto.Changeset{}}

  """
  def delete_collector(%Collector{} = collector, organization_ids) do
    if collector.organization_id in organization_ids do
      Repo.delete(collector)
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking collector changes.

  ## Examples

      iex> change_collector(collector)
      %Ecto.Changeset{data: %Collector{}}

  """
  def change_collector(%Collector{} = collector, attrs \\ %{}) do
    Collector.changeset(collector, attrs)
  end

  defp maybe_add_quests(changeset, attrs) do
    quest_ids = Map.get(attrs, "quest_ids", [])

    case quest_ids do
      [] ->
        # If no quest_ids are provided, do not attempt to update the quests association.
        changeset

      _ ->
        # Proceed only if quest_ids are provided
        with {:ok, quest_ids} <- add_quest_start_if_valid(quest_ids, attrs) do
          quests = Repo.all(from q in Quest, where: q.id in ^quest_ids)

          # Only update the association if quests are found; otherwise, leave it unchanged.
          if Enum.empty?(quests) do
            changeset
          else
            Ecto.Changeset.put_assoc(changeset, :quests, quests)
          end
        else
          # Handle invalid quest_start ID by adding an error, or you might choose to ignore it
          {:error, _} ->
            Ecto.Changeset.add_error(changeset, :quest_start, "Invalid quest start ID.")
        end
    end
  end

  defp add_quest_start_if_valid(quest_ids, attrs) do
    case Map.get(attrs, "quest_start") do
      nil ->
        {:ok, quest_ids}

      quest_start_id ->
        # Check if quest_start_id exists in the database
        case Repo.get(Quest, quest_start_id) do
          nil -> {:error, :not_found}
          _quest -> {:ok, List.insert_at(quest_ids, -1, quest_start_id)}
        end
    end
  end
end
