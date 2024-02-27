defmodule QuestApiV21.Accountquests do
  @moduledoc """
  The Accountquests context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo

  alias QuestApiV21.Accountquests.AccountQuest

  @doc """
  Returns the list of accountquest.

  ## Examples

      iex> list_accountquest()
      [%AccountQuest{}, ...]

  """
  def list_accountquest do
    Repo.all(AccountQuest)
  end

  @doc """
  Gets a single account_quest.

  Raises `Ecto.NoResultsError` if the Account quest does not exist.

  ## Examples

      iex> get_account_quest!(123)
      %AccountQuest{}

      iex> get_account_quest!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account_quest!(id), do: Repo.get!(AccountQuest, id)

  @doc """
  Creates a account_quest.

  ## Examples

      iex> create_account_quest(%{field: value})
      {:ok, %AccountQuest{}}

      iex> create_account_quest(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account_quest(attrs \\ %{}) do
    %AccountQuest{}
    |> AccountQuest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account_quest.

  ## Examples

      iex> update_account_quest(account_quest, %{field: new_value})
      {:ok, %AccountQuest{}}

      iex> update_account_quest(account_quest, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_quest(%AccountQuest{} = account_quest, attrs) do
    account_quest
    |> AccountQuest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account_quest.

  ## Examples

      iex> delete_account_quest(account_quest)
      {:ok, %AccountQuest{}}

      iex> delete_account_quest(account_quest)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account_quest(%AccountQuest{} = account_quest) do
    Repo.delete(account_quest)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account_quest changes.

  ## Examples

      iex> change_account_quest(account_quest)
      %Ecto.Changeset{data: %AccountQuest{}}

  """
  def change_account_quest(%AccountQuest{} = account_quest, attrs \\ %{}) do
    AccountQuest.changeset(account_quest, attrs)
  end
end
