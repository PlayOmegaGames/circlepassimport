defmodule QuestApiV21.Collection_Points do
  @moduledoc """
  The Collection_Points context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo

  alias QuestApiV21.Collection_Points.Collection_Point

  @doc """
  Returns the list of collection_point.

  ## Examples

      iex> list_collection_point()
      [%Collection_Point{}, ...]

  """
  def list_collection_point do
    Repo.all(Collection_Point)
  end

  @doc """
  Gets a single collection__point.

  Raises `Ecto.NoResultsError` if the Collection  point does not exist.

  ## Examples

      iex> get_collection__point!(123)
      %Collection_Point{}

      iex> get_collection__point!(456)
      ** (Ecto.NoResultsError)

  """
  def get_collection__point!(id), do: Repo.get!(Collection_Point, id)

  @doc """
  Creates a collection__point.

  ## Examples

      iex> create_collection__point(%{field: value})
      {:ok, %Collection_Point{}}

      iex> create_collection__point(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_collection__point(attrs \\ %{}) do
    %Collection_Point{}
    |> Collection_Point.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a collection__point.

  ## Examples

      iex> update_collection__point(collection__point, %{field: new_value})
      {:ok, %Collection_Point{}}

      iex> update_collection__point(collection__point, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_collection__point(%Collection_Point{} = collection__point, attrs) do
    collection__point
    |> Collection_Point.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a collection__point.

  ## Examples

      iex> delete_collection__point(collection__point)
      {:ok, %Collection_Point{}}

      iex> delete_collection__point(collection__point)
      {:error, %Ecto.Changeset{}}

  """
  def delete_collection__point(%Collection_Point{} = collection__point) do
    Repo.delete(collection__point)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking collection__point changes.

  ## Examples

      iex> change_collection__point(collection__point)
      %Ecto.Changeset{data: %Collection_Point{}}

  """
  def change_collection__point(%Collection_Point{} = collection__point, attrs \\ %{}) do
    Collection_Point.changeset(collection__point, attrs)
  end
end
