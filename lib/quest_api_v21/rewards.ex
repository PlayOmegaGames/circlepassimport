defmodule QuestApiV21.Rewards do
  @moduledoc """
  The Rewards context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo
  alias QuestApiV21.Quests

  alias QuestApiV21.Rewards.Reward

  @doc """
  Returns the list of reward.

  ## Examples

      iex> list_reward()
      [%Reward{}, ...]

  """
  def list_reward do
    Repo.all(Reward)
  end

  @doc """
  Gets a single reward.

  Raises `Ecto.NoResultsError` if the Reward does not exist.

  ## Examples

      iex> get_reward!(123)
      %Reward{}

      iex> get_reward!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reward!(id), do: Repo.get!(Reward, id)

  @doc """
  Creates a reward.

  ## Examples

      iex> create_reward(%{field: value})
      {:ok, %Reward{}}

      iex> create_reward(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

      alias QuestApiV21.Rewards
      alias QuestApiV21.Repo
      quest = Repo.get(QuestApiV21.Quests.Quest, "310d6448-d5b9-4121-9f6c-80ebd25eca13")
      organization = Repo.get(QuestApiV21.Organizations.Organization, "eec83871-edf0-430f-afbf-6b4c2df3399c")
      attrs = %{quest_id: quest.id, account_id: "faee5fb5-4fd9-4271-8803-0bc8ac3cfa29"}
      {:ok, reward} = Rewards.create_reward(attrs, organization.id)




  """
  def create_reward(attrs, organization_id) do
    quest_id = Map.get(attrs, :quest_id)

    case Quests.get_quest(quest_id, organization_id) do
      nil ->
        {:error, "Quest not found"}
      quest ->
        quest_name = quest.name

        attrs = Map.put(attrs, :reward_name, quest_name)
        attrs = Map.put(attrs, :organization_id, organization_id)

        %Reward{}
        |> Reward.changeset(attrs)
        |> Repo.insert()
    end
  end

  @doc """
  Updates a reward.

  ## Examples

      iex> update_reward(reward, %{field: new_value})
      {:ok, %Reward{}}

      iex> update_reward(reward, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reward(%Reward{} = reward, attrs) do
    reward
    |> Reward.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a reward.

  ## Examples

      iex> delete_reward(reward)
      {:ok, %Reward{}}

      iex> delete_reward(reward)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reward(%Reward{} = reward) do
    Repo.delete(reward)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reward changes.

  ## Examples

      iex> change_reward(reward)
      %Ecto.Changeset{data: %Reward{}}

  """
  def change_reward(%Reward{} = reward, attrs \\ %{}) do
    Reward.changeset(reward, attrs)
  end
end
