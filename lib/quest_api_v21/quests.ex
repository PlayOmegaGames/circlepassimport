defmodule QuestApiV21.Quests do
  @moduledoc """
  The Quests context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Collectors.Collector

  @doc """
  Returns the list of quests.

  ## Examples

      iex> list_quests()
      [%Quest{}, ...]

  """
  def list_quests do
    Repo.all(Quest)
  end

  def list_quests_by_organization_ids(organization_ids) do
    IO.inspect(organization_ids, label: "Organization IDs")

    query = filter_by_organization_ids(Quest, organization_ids)
    IO.inspect(query, label: "Filtered Query")

    quests = query |> Repo.preload([:organization, :badges, :collectors]) |> Repo.all()
    IO.inspect(quests, label: "Preloaded Quests")

    quests
  end

  defp filter_by_organization_ids(query, organization_ids) do
    from quest in query,
    join: org in assoc(quest, :organization),
    where: org.id in ^organization_ids
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
  def get_quest!(id), do: Repo.get!(Quest, id)

  @doc """
  Creates a quest.

  ## Examples

      iex> create_quest(%{field: value})
      {:ok, %Quest{}}

      iex> create_quest(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """


  def create_quest_with_organization(quest_params, organization_id) do
    IO.inspect(quest_params, label: "Quest Params")
    IO.inspect(organization_id, label: "Organization ID")

    %Quest{}
    |> Quest.changeset(Map.put(quest_params, "organization_id", organization_id))
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
  def update_quest(%Quest{} = quest, attrs) do
    quest
    |> Quest.changeset(attrs)
    |> maybe_add_collectors(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a quest.

  ## Examples

      iex> delete_quest(quest)
      {:ok, %Quest{}}

      iex> delete_quest(quest)
      {:error, %Ecto.Changeset{}}

  """
  def delete_quest(%Quest{} = quest) do
    Repo.delete(quest)
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
      nil -> changeset
      collector_ids ->
        collectors = Repo.all(from c in Collector, where: c.id in ^collector_ids)
        Ecto.Changeset.put_assoc(changeset, :collectors, collectors)
    end
  end

end
