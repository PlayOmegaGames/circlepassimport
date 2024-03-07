defmodule QuestApiV21.OrganizationScopedQueries do
  import Ecto.Query
  alias QuestApiV21.Repo

  @doc """
  Scopes a query to only include records associated with the given organization ID.

  If no organization ID is provided, returns all records.

  ## Parameters

  - queryable: The Ecto queryable (schema or query).
  - organization_id: The organization ID to scope the query.

  ## Examples

      iex> OrganizationScopedQueries.scope_query(Quest, org_id)
      [%Quest{}, ...]
  """
    def scope_query(queryable, organization_id, preloads \\ []) do
      if is_nil(organization_id) do
        []
      else
        query =
          queryable
          |> where([q], q.organization_id == ^organization_id)
          |> preload(^preloads)
          |> Repo.all()

        query
      end
    end

    def org_scope_query(queryable, host_id, preloads \\ []) do
      # Query the Organization schema
      query =
        from(o in queryable,
          join: ho in "hosts_organizations", on: ho.organization_id == o.id,
          join: h in QuestApiV21.Hosts.Host, on: h.id == ho.host_id and h.id == ^host_id,
          preload: ^preloads
        )

      Repo.all(query)
    end



  @doc """
  Retrieves a single item by its ID, scoped to the given organization ID.

  If no organization ID is provided, retrieves the item without scoping.

  ## Parameters

  - queryable: The Ecto queryable (schema or query).
  - id: The ID of the item to retrieve.
  - organization_id: The organization ID to scope the query.

  ## Examples

      iex> OrganizationScopedQueries.get_item(Quest, quest_id, org_id)
      %Quest{}
  """
  def get_item(queryable, id, organization_id, preloads \\ []) do
      IO.inspect(queryable)
    _query =
      queryable
      |> where([q], q.id == ^id)

    query =
      if is_nil(organization_id) do
        queryable
      else
        queryable |> where([q], q.organization_id == ^organization_id)
      end

    query
    |> preload(^preloads)
    |> Repo.one()
  end

  @doc """
  Updates a record if it belongs to the given organization ID.

  If no organization ID is provided, updates the item without scoping.

  ## Parameters

  - queryable: The Ecto queryable (schema or query).
  - id: The ID of the item to update.
  - organization_id: The organization ID to scope the query.
  - update_fn: A function that takes the item and returns an Ecto.Changeset.

  ## Examples

      iex> OrganizationScopedQueries.update_item(Quest, quest_id, org_id, update_fn)
      {:ok, %Quest{}}
  """
  def update_item(queryable, id, organization_id, update_fn) do
    get_item(queryable, id, organization_id)
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
  Deletes a record if it belongs to the given organization ID.

  If no organization ID is provided, deletes the item without scoping.

  ## Parameters

  - queryable: The Ecto queryable (schema or query).
  - id: The ID of the item to delete.
  - organization_id: The organization ID to scope the query.

  ## Examples

      iex> OrganizationScopedQueries.delete_item(Quest, quest_id, org_id)
      {:ok, %Quest{}}
  """
  def delete_item(queryable, id, organization_id) do
    get_item(queryable, id, organization_id)
    |> case do
      nil -> {:error, :not_found}
      item -> Repo.delete(item)
    end
  end
end
