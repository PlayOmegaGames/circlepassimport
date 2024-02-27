defmodule QuestApiV21.OrganizationScopedQueries do
  import Ecto.Query
  alias QuestApiV21.Repo

  @doc """
  Scopes a query to only include records associated with the given organization IDs.

  ## Parameters

  - queryable: The Ecto queryable (schema or query).
  - organization_ids: A list of organization IDs to scope the query.

  ## Examples

      iex> OrganizationScopedQueries.scope_query(Quest, [org_id])
      [%Quest{}, ...]
  """
  def scope_query(queryable, organization_ids, preloads \\ []) do
    queryable
    |> where([q], q.organization_id in ^organization_ids)
    |> preload(^preloads)
    |> Repo.all()
  end

  @doc """
  Retrieves a single item by its ID, scoped to the given organization IDs.

  ## Parameters

  - queryable: The Ecto queryable (schema or query).
  - i d: The ID of the item to retrieve.
  - organization_ids: A list of organization IDs to scope the query.

  ## Examples

      iex> OrganizationScopedQueries.get_item(Quest, quest_id, [org_id])
      %Quest{}
  """
  def get_item(queryable, id, organization_id, preloads \\ []) do
    queryable
    |> where([q], q.id == ^id and q.organization_id == ^organization_id)
    |> preload(^preloads)
    |> Repo.one()
  end

  @doc """
  Updates a record if it belongs to the given organization IDs.

  ## Parameters

  - queryable: The Ecto queryable (schema or query).
  - id: The ID of the item to update.
  - organization_ids: A list of organization IDs to scope the query.
  - update_fn: A function that takes the item and returns an Ecto.Changeset.

  ## Examples

      iex> OrganizationScopedQueries.update_item(Quest, quest_id, [org_id], update_fn)
      {:ok, %Quest{}}
  """
  def update_item(queryable, id, organization_ids, update_fn) do
    get_item(queryable, id, organization_ids)
    |> case do
      nil ->
        {:error, :not_found}

      item ->
        item
        |> update_fn.()
        |> Repo.update()
    end
  end

  @doc """
  Deletes a record if it belongs to the given organization IDs.

  ## Parameters

  - queryable: The Ecto queryable (schema or query).
  - id: The ID of the item to delete.
  - organization_ids: A list of organization IDs to scope the query.

  ## Examples

      iex> OrganizationScopedQueries.delete_item(Quest, quest_id, [org_id])
      {:ok, %Quest{}}
  """
  def delete_item(queryable, id, organization_ids) do
    get_item(queryable, id, organization_ids)
    |> case do
      nil -> {:error, :not_found}
      item -> Repo.delete(item)
    end
  end

  # You can add more functions as necessary...
end
