defmodule QuestApiV21.Badges do
  @moduledoc """
  The Badges context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo
  alias QuestApiV21.Accounts.Account

  alias QuestApiV21.Badges.Badge

  @doc """
  Returns the list of badge.

  ## Examples

      iex> list_badge()
      [%Badge{}, ...]

  """
  def list_badge do
    Repo.all(Badge)
  end

  @doc """
  Gets a single badge.

  Raises `Ecto.NoResultsError` if the Collection  point does not exist.

  ## Examples

      iex> get_badge!(123)
      %Badge{}

      iex> get_badge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_badge!(id), do: Repo.get!(Badge, id)

  @doc """
  Creates a badge.

  ## Examples

      iex> create_badge(%{field: value})
      {:ok, %Badge{}}

      iex> create_badge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_badge(attrs \\ %{}) do
    %Badge{}
    |> Badge.changeset(attrs)
    |> maybe_add_accounts(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a badge.

  ## Examples

      iex> update_badge(badge, %{field: new_value})
      {:ok, %Badge{}}

      iex> update_badge(badge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_badge(%Badge{} = badge, attrs) do
    badge
    |> Badge.changeset(attrs)
    |> maybe_add_accounts(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a badge.

  ## Examples

      iex> delete_badge(badge)
      {:ok, %Badge{}}

      iex> delete_badge(badge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_badge(%Badge{} = badge) do
    Repo.delete(badge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking badge changes.

  ## Examples

      iex> change_badge(badge)
      %Ecto.Changeset{data: %Badge{}}

  """
  def change_badge(%Badge{} = badge, attrs \\ %{}) do
    Badge.changeset(badge, attrs)
  end

  defp maybe_add_accounts(changeset, attrs) do
    case Map.get(attrs, "accounts_id") do
      nil -> changeset
      account_ids ->
        accounts = Repo.all(from a in Account, where: a.id in ^account_ids)
        Ecto.Changeset.put_assoc(changeset, :accounts, accounts)
    end
  end

end
