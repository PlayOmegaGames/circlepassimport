defmodule QuestApiV21.Rewards do
  @moduledoc """
  The Rewards context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.OrganizationScopedQueries
  alias QuestApiV21.Repo
  alias QuestApiV21.Quests
  alias QuestApiV21.Accounts.Account

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

  def list_rewards_by_organization_id(organization_id) do
    preloads = [:organization, :account, :quest]
    OrganizationScopedQueries.scope_query(Reward, organization_id, preloads)
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
  def get_reward!(id) do
    Repo.get!(Reward, id)
    |> Repo.preload([:organization, :account, :quest])
  end
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
  def create_reward(attrs) do
    quest_id = Map.get(attrs, :quest_id)

    # Check if a reward string is directly provided in the attributes
    case Map.get(attrs, :reward_name) do
      nil ->
        # No reward_name provided, retrieve details from the quest
        case Quests.get_quest(quest_id) do
          %Quests.Quest{} = quest ->
            organization_id = quest.organization_id
            reward_name = quest.reward

            updated_attrs = Map.put_new(attrs, :reward_name, reward_name)
            updated_attrs = Map.put_new(updated_attrs, :organization_id, organization_id)

            %Reward{}
            |> Reward.changeset(updated_attrs)
            |> Repo.insert()

          _ ->
            {:error, "Quest not found"}
        end

      reward_name ->
        # reward_name provided, proceed to create reward
        # Ensure organization_id is managed appropriately
        organization_id = Map.get(attrs, :organization_id, nil)

        updated_attrs = Map.put_new(attrs, :reward_name, reward_name)
        updated_attrs = Map.put_new(updated_attrs, :organization_id, organization_id)

        %Reward{}
        |> Reward.changeset(updated_attrs)
        |> Repo.insert()
    end
  end

  @doc """
  Lists all rewards associated with a specific account.

  ## Examples

    alias QuestApiV21.Rewards
    Rewards.list_rewards_for_account("d26326d1-be5b-4a24-a82e-57d855f95b89")
  """
  def list_rewards_for_account(account_id) do
    Repo.all(
      from r in Reward,
        where: r.account_id == ^account_id,
        preload: [:organization, :quest]
    )
  end

  # Function for displaying rewards on home
  def get_rewards_for_account(account_id) do
    account_query =
      from(a in Account,
        where: a.id == ^account_id,
        preload: [rewards: [:organization, :quest]]
      )

    case Repo.one(account_query) do
      nil ->
        {:error, :not_found}

      account ->
        {:ok, account.rewards}
    end
  end

  @doc """
  Redeems a reward based on the organization ID and slug by setting its redeemed field to true.

  ## Examples

    alias QuestApiV21.Rewards
    Rewards.redeem_reward_by_slug("eec83871-edf0-430f-afbf-6b4c2df3399c", "reward-test-f95b89")

  """
  def redeem_reward_by_slug(organization_id, slug) do
    case Repo.get_by(Reward, organization_id: organization_id, slug: slug) do
      nil ->
        {:error, :not_found}

      %Reward{redeemed: true} ->
        {:error, :already_redeemed}

      %Reward{} = unredeemed_reward ->
        unredeemed_reward
        |> Reward.changeset(%{redeemed: true})
        |> Repo.update()
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
