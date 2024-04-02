defmodule QuestApiV21.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.OrganizationScopedQueries
  alias QuestApiV21.Repo

  alias QuestApiV21.Transactions.Transaction

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Repo.all(Transaction)
  end

  def list_transactions_bg_organization_id(organization_id) do
    preloads = [:account, :badge]
    OrganizationScopedQueries.scope_query(Transaction, organization_id, preloads)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a transaction for a given badge and account.

  Example
  alias QuestApiV21.Repo
  alias QuestApiV21.Transactions.Transaction
  alias QuestApiV21.Badges
  badge = Repo.get!(Badges.Badge, "05b4cf17-e2b7-4e7a-92fe-63143ece098a")
  account = Repo.get!(QuestApiV21.Accounts.Account, "1f4223ea-813e-42e5-a82a-8e568e7ec6c3")
  {:ok, transaction} = QuestApiV21.Transactions.create_transaction_for_badge_account(badge.id, account.id)


  """
  def create_transaction_for_badge_account(badge_id, account_id) do
    badge = Repo.get!(QuestApiV21.Badges.Badge, badge_id)
    organization_id = badge.organization_id
    badge_points = badge.badge_points

    %QuestApiV21.Transactions.Transaction{}
    |> Transaction.changeset(%{
      badge_id: badge_id,
      account_id: account_id,
      lp_badge: badge_points,
      organization_id: organization_id
    })
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
