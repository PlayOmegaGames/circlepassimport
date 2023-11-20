defmodule QuestApiV21.Collectors do
  @moduledoc """
  The Collectors context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo
  alias QuestApiV21.Collectors.Collector

  alias QuestApiV21.Quests.Quest


  @doc """
  Returns the list of collectors.

  ## Examples

      iex> list_collectors()
      [%Collector{}, ...]

  """
  def list_collectors do
    Repo.all(Collector)
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
  def get_collector!(id), do: Repo.get!(Collector, id)

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

  def create_collector_with_organization(collector_params, organization_id) do
    %Collector{}
      |> Collector.changeset(Map.put(collector_params, "organization_id", organization_id))
      |> maybe_add_quests(collector_params)
      |> Repo.insert()
  end

  @doc """
  Updates a collector.

  ## Examples

      iex> update_collector(collector, %{field: new_value})
      {:ok, %Collector{}}

      iex> update_collector(collector, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_collector(%Collector{} = collector, attrs) do
    collector
    |> Collector.changeset(attrs)
    |> maybe_add_quests(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a collector.

  ## Examples

      iex> delete_collector(collector)
      {:ok, %Collector{}}

      iex> delete_collector(collector)
      {:error, %Ecto.Changeset{}}

  """
  def delete_collector(%Collector{} = collector) do
    Repo.delete(collector)
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
    # Retrieve existing quest_ids, default to an empty list if not present
    quest_ids = Map.get(attrs, "quest_ids", [])

    # Check and add quest_start if it's a valid quest ID
    with {:ok, quest_ids} <- add_quest_start_if_valid(quest_ids, attrs) do
      # Fetch quests from the database based on quest_ids
      quests = Repo.all(from q in Quest, where: q.id in ^quest_ids)
      # Associate quests with the collector
      Ecto.Changeset.put_assoc(changeset, :quests, quests)
    else
      # Handle invalid quest_start ID
      {:error, _} ->
        Ecto.Changeset.add_error(changeset, :quest_start, "Invalid quest start ID.")
    end
  end

  defp add_quest_start_if_valid(quest_ids, attrs) do
    case Map.get(attrs, "quest_start") do
      nil -> {:ok, quest_ids}
      quest_start_id ->
        # Check if quest_start_id exists in the database
        case Repo.get(Quest, quest_start_id) do
          nil -> {:error, :not_found}
          _quest -> {:ok, List.insert_at(quest_ids, -1, quest_start_id)}
        end
    end
  end
end
