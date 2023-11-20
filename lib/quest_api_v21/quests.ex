  defmodule QuestApiV21.Quests do
    @moduledoc """
    The Quests context.
    """

    import Ecto.Query, warn: false
    alias QuestApiV21.OrganizationScopedQueries
    alias QuestApiV21.Quests.Quest
    alias QuestApiV21.Collectors.Collector
    alias QuestApiV21.Accounts.Account
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

    #only returns the quests that are associated to that record


    def list_quests_by_organization_ids(organization_ids) do
      preloads = [:organization, :badges, :collectors, :accounts]
      OrganizationScopedQueries.scope_query(Quest, organization_ids, preloads)
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
    def get_quest(id, organization_ids) do
      preloads = [:organization, :badges, :collectors, :accounts]
      OrganizationScopedQueries.get_item(Quest, id, organization_ids, preloads)
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
    def update_quest(%Quest{} = quest, attrs, organization_ids) do
      if quest.organization_id in organization_ids do
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

    defp maybe_add_accounts(changeset, attrs) do
      case Map.get(attrs, "account_ids") do
        nil -> changeset
        account_ids ->
          accounts = Repo.all(from a in Account, where: a.id in ^account_ids)
          Ecto.Changeset.put_assoc(changeset, :accounts, accounts)
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
