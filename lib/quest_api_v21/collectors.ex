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
    case Map.get(attrs, "quest_ids") do
      nil -> changeset
      quest_ids ->
        quests = Repo.all(from q in Quest, where: q.id in ^quest_ids)
        Ecto.Changeset.put_assoc(changeset, :quests, quests)
    end
  end

end
