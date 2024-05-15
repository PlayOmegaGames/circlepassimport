defmodule QuestApiV21.GordianKnot do
  import Ecto.Query, warn: false
  alias QuestApiV21.Repo
  alias QuestApiV21.Quests.Quest
  alias QuestApiV21.Quests
  alias QuestApiV21.Rewards
  alias QuestApiV21.Rewards.Reward
  alias QuestApiV21.Accounts
  alias QuestApiV21.Badges
  alias QuestApiV21.Accounts.Account
  alias QuestApiV21.Transactions
  alias QuestApiV21.Transactions.Transaction
  alias Bcrypt
  require Logger

  def add_badge_to_account(account_id, badge_id) do
    Logger.info("Starting to add badge to account #{account_id}")

    Repo.transaction(fn ->
      account = Repo.get!(Account, account_id) |> Repo.preload([:badges])
      badge = Badges.get_badge!(badge_id)

      if badge.loyalty_badge do
        Logger.info("Executing loyalty_badge function for badge #{badge_id}")
        updated_badges = [badge | account.badges]

        account =
          Ecto.Changeset.change(account)
          |> Ecto.Changeset.put_assoc(:badges, updated_badges)
          |> Repo.update!()

        Logger.info("Successfully added new loyalty badge to account")
        update_quest_stats(account, badge.quest_id)

        add_loyalty_badge(badge, account)
      else
        if Enum.any?(account.badges, &(&1.id == badge_id)) do
          Logger.info("Badge #{badge_id} already associated with account #{account_id}")

          {:error, :badge_already_associated}
        else
          Logger.info("Adding new badge to account")

          updated_badges = [badge | account.badges]

          account =
            Ecto.Changeset.change(account)
            |> Ecto.Changeset.put_assoc(:badges, updated_badges)
            |> Repo.update!()

          Logger.info("Successfully added new badge to account")
          update_quest_stats(account, badge.quest_id)
          Transactions.create_transaction_for_badge_account(badge_id, account_id)

          {:ok, "Badge added and quest completion checked"}
        end
      end
    end)
    |> handle_transaction_result()
  end

  defp handle_transaction_result({:ok, _result}) do
    {:ok, "Operation successfully completed"}
  end

  defp handle_transaction_result({:error, reason}) do
    {:error, reason}
  end

  # Private function to update quest stats and handle reward generation for an account and quest
  defp update_quest_stats(account, quest_id) do
    quest = Quests.get_quest(quest_id)
    # Attempt to add the quest to the account if it's not already associated.
    # This could be part of ensuring that the quest is tracked once a related badge is added.
    add_quest_to_account_if_needed(account.id, quest_id)
    |> case do
      # If the quest was successfully added or already exists, increment the account's quest stats.
      # This likely increases a counter of quests that the account is participating in or has completed.
      :ok -> increment_quests_stats(account)
      # If adding the quest was not necessary (e.g., already associated), do nothing (:noop).
      _ -> :noop
    end

    # Ignore if loyalty quest existss
    if is_nil(quest.quest_loyalty) do
      # Check if the addition of a badge has completed the quest and, if so, create a reward.
      check_quest_completion_and_create_reward(account.id, quest_id)
      |> case do
        # If a reward was successfully created (indicating the quest was completed), increment the rewards stats.
        # This adjusts a counter indicating how many rewards the account has received.
        {:ok, _reward} -> increment_rewards_stats(account)
        # If no reward was created (quest not completed or other failure), do nothing (:noop).
        _ -> :noop
      end
    end
  end

  defp increment_rewards_stats(account) do
    # Query the count of rewards associated with the account
    rewards_count =
      Repo.aggregate(from(r in Reward, where: r.account_id == ^account.id), :count, :id)

    # Update the account's rewards_stats with the actual count of associated rewards
    account
    |> Ecto.Changeset.change(rewards_stats: rewards_count)
    |> Repo.update!()
  end

  defp add_quest_to_account_if_needed(account_id, quest_id) do
    account = Repo.get!(Account, account_id) |> Repo.preload(:quests)

    unless Enum.any?(account.quests, &(&1.id == quest_id)) do
      Logger.info(
        "Quest #{quest_id} is not associated with account #{account_id}. Associating and updating selected quest."
      )

      # Associate the quest with the account if it's not already associated
      result = add_quest_to_account(account_id, quest_id)

      case result do
        {:ok, _message} ->
          # If the quest was successfully added, update the selected quest
          update_selected_quest_for_user(account_id, quest_id)

        {:error, _reason} ->
          # Handle error appropriately if needed
          Logger.error("Failed to associate quest #{quest_id} with account #{account_id}.")
      end
    else
      Logger.info(
        "Quest #{quest_id} is already associated with account #{account_id}. Updating selected quest."
      )

      # If the quest is already associated but not selected, update the selected quest
      update_selected_quest_for_user(account_id, quest_id)
    end
  end

  def check_quest_completion_and_create_reward(account_id, quest_id) do
    # Ensure to preload the :badges association directly before checking quest completion
    account =
      Repo.get!(Account, account_id)
      |> Repo.preload(:badges)

    if quest_completed?(account, quest_id) do
      Logger.info("Quest #{quest_id} completed. Creating reward.")

      # Assuming create_reward function takes a map with :account_id and :quest_id
      case Rewards.create_reward(%{account_id: account.id, quest_id: quest_id}) do
        {:ok, reward} ->
          Logger.info("Reward created successfully: #{inspect(reward)}")
          {:ok, reward}

        {:error, _error} ->
          Logger.error("Failed to create reward for account #{account_id} and quest #{quest_id}")
          {:error, :failed_to_create_reward}
      end
    else
      Logger.info("Quest #{quest_id} not completed for account #{account_id}. No reward created.")
      {:ok, "Quest not completed"}
    end
  end

  def quest_completed?(account, quest_id) do
    quest = Repo.get!(Quest, quest_id)
    number_of_required_badges = quest.badge_count

    # Fetching the count of unique badges collected by the account for this specific quest
    number_of_collected_badges =
      Enum.filter(account.badges, fn badge -> badge.quest_id == quest_id end)
      |> Enum.count()

    # Logging for debugging purposes
    Logger.info("Required number of badges for quest completion: #{number_of_required_badges}")

    Logger.info(
      "Number of badges collected by account #{account.id} for quest #{quest_id}: #{number_of_collected_badges}"
    )

    # The quest is considered completed if the number of collected badges matches the required count
    number_of_collected_badges == number_of_required_badges
  end

  def add_quest_to_account(user_id, quest_id) do
    account = Repo.get!(Account, user_id) |> Repo.preload(:quests)

    # Check if the quest is already associated with the account
    if Enum.any?(account.quests, &(&1.id == quest_id)) do
      Logger.info(
        "Quest #{quest_id} is already associated with account #{user_id}. Updating selected quest."
      )

      update_selected_quest_for_user(account.id, quest_id)
      {:ok, :already_associated}
    else
      Logger.info(
        "Adding new quest #{quest_id} to account #{user_id} and updating selected quest."
      )

      quest = Repo.get!(Quest, quest_id)

      updated_quests = [quest | account.quests]

      case Repo.transaction(fn ->
             # Update the account with the new list of quests
             Repo.update!(
               Ecto.Changeset.change(account)
               |> Ecto.Changeset.put_assoc(:quests, updated_quests)
             )

             # Increment quest stats
             increment_quests_stats(account.id)
             # Now explicitly update the selected_quest_id
             update_selected_quest_for_user(account.id, quest_id)
           end) do
        {:ok, _} ->
          Logger.info(
            "Successfully added quest #{quest_id} and updated selected quest for account #{user_id}. Quest stats incremented."
          )

          {:ok, "Quest added and selected quest updated, quest stats incremented"}

        {:error, reason} ->
          Logger.error(
            "Failed to add quest #{quest_id} or update selected quest for account #{user_id}: #{inspect(reason)}"
          )

          {:error, "Failed to add quest or update selected quest"}
      end
    end
  end

  defp increment_quests_stats(account_id) do
    account = Repo.get!(Account, account_id)
    new_quests_stats = account.quests_stats + 1

    Logger.info("Incrementing quest stats for account #{account_id} to #{new_quests_stats}.")

    case Ecto.Changeset.change(account, quests_stats: new_quests_stats) |> Repo.update() do
      {:ok, _account} ->
        Logger.info("Quest stats successfully incremented for account #{account_id}.")
        {:ok}

      {:error, _changeset} ->
        Logger.error("Failed to increment quest stats for account #{account_id}.")
        {:error, "Failed to update quest stats"}
    end
  end

  # Function to update the selected_quest field for an account
  def update_selected_quest_for_user(account_id, quest_id) do
    account = Repo.get!(Account, account_id)
    changeset = Ecto.Changeset.change(account, %{selected_quest_id: quest_id})

    case Repo.update(changeset) do
      {:ok, _account} ->
        # Assuming you have a way to fetch the quest name efficiently
        quest_name = Repo.get!(Quest, quest_id) |> Map.get(:name)

        # Broadcast the update along with additional details
        Phoenix.PubSub.broadcast(
          QuestApiV21.PubSub,
          "accounts:#{account_id}",
          %{
            event: "selected_quest_updated",
            quest_id: quest_id,
            quest_name: quest_name
            # Include any other details here as necessary
          }
        )

        Logger.info("Broadcasting quest update for account #{account_id}")

        {:ok, account}

      {:error, _changeset} = error ->
        error
    end
  end

  def authenticate_user(email, password) do
    case Accounts.find_account_by_email(email) do
      nil ->
        {:error, :not_found}

      account ->
        if Bcrypt.verify_pass(password, account.hashed_password) do
          {:ok, account}
        else
          {:error, :unauthorized}
        end
    end
  end

  def authenticate_user_by_id(_email, id, password) do
    # IO.inspect("Authenticate User Function")

    case Accounts.find_account_by_id(id) do
      nil ->
        {:error, :not_found}

      account ->
        if Bcrypt.verify_pass(password, account.hashed_password) do
          {:ok, account}
        else
          {:error, :unauthorized}
        end
    end
  end

  # for the show collector function

  @doc """

  the function that handles adding a badge to a user

  Example

  alias QuestApiV21.Repo
  alias QuestApiV21.Accounts.Account
  alias QuestApiV21.Accounts
  alias QuestApiV21.Badges.Badge

  badge = Repo.get(Badge, "9b7015b1-c4bb-4323-b7d2-98f881036553")
  {:ok, message, updated_account} = Accounts.add_badge_to_user("d26326d1-be5b-4a24-a82e-57d855f95b89", badge)
  """

  # This function determines if the given account has any active (i.e., incomplete) quests.
  def has_active_quests?(account_id) do
    # Fetch the account by its ID, raising an error if it's not found.
    account = Repo.get!(Account, account_id)

    # Preload the associated badges and quests for the account to reduce database queries.
    user_with_badges_and_quests = Repo.preload(account, [:badges, :quests])

    # Iterate over the quests associated with the user to check for any that are not completed.
    Enum.any?(user_with_badges_and_quests.quests, fn quest ->
      # If any quest is found to be incomplete (by calling `quest_completed?`), return true.
      not quest_completed?(user_with_badges_and_quests, quest.id)
    end)
  end

  # ===== Loyalty Badge System =====

  def add_loyalty_badge(badge, account) do
    # Log the start of the loyalty transaction check process
    Logger.info(
      "Checking for loyalty transactions for badge #{badge.id} and account #{account.id}"
    )

    # Preload necessary associations for the account
    account = Repo.preload(account, [:badges, :quests])

    # Retrieve the quest associated with the badge
    quest = Quests.get_quest(badge.quest_id)

    # Fetch the latest transaction for the given account and badge, ordered by the insertion timestamp in descending order
    latest_transaction =
      Repo.one(
        from t in Transaction,
          where: t.account_id == ^account.id and t.badge_id == ^badge.id,
          order_by: [desc: t.inserted_at],
          limit: 1
      )

    # Calculate the total loyalty points for the account by summing the lp_badge field of all transactions for the account and badge
    total_lp_badge =
      Repo.one(
        from t in Transaction,
          where: t.account_id == ^account.id and t.badge_id == ^badge.id,
          select: coalesce(sum(t.lp_badge), 0)
      ) || 0

    new_total_lp_badge = total_lp_badge + badge.badge_points
    # Get the current time in UTC
    current_time = DateTime.utc_now()

    # Convert the inserted_at timestamp of the latest transaction to UTC
    transaction_inserted_utc =
      latest_transaction && DateTime.from_naive!(latest_transaction.inserted_at, "Etc/UTC")

    # Log the timestamp of the latest transaction for debugging purposes
    Logger.info("Latest transaction timestamp: #{transaction_inserted_utc}")

    # Check if no transactions exist or if the cooldown period has passed since the last transaction
    if is_nil(latest_transaction) or
         DateTime.compare(
           DateTime.add(transaction_inserted_utc, badge.cool_down_reset * 3600),
           current_time
         ) == :lt do
      # Start a transaction to ensure atomicity
      Repo.transaction(fn ->
        # If the quest has loyalty conditions, decode the quest loyalty JSON and check the conditions
        if quest && quest.quest_loyalty not in [nil, ""] do
          case Jason.decode(quest.quest_loyalty) do
            {:ok, reward_map} ->
              # Iterate over the reward map and check if the total loyalty points meet the conditions to create rewards
              Enum.find(reward_map, fn {num, reward} ->
                num = String.to_integer(num)
                # Logger.info("total points: #{total_lp_badge}")
                # Logger.info("badge points: #{badge.badge_points}")
                if total_lp_badge < num and new_total_lp_badge >= num do
                  # Log success if the account meets the conditions for the quest and create the reward
                  Logger.info(
                    "Success: Account #{account.id} meets the conditions for quest #{quest.name}: #{num}"
                  )

                  Rewards.create_reward(%{
                    quest_id: badge.quest_id,
                    account_id: account.id,
                    reward_name: reward,
                    organization_id: quest.organization_id
                  })

                  # Return true to stop further iteration
                  true
                else
                  # Log failure if the account does not meet the conditions for the quest
                  Logger.info(
                    "Failure: Account #{account.id} does not meet the conditions for quest #{quest.name}"
                  )

                  # Continue iteration
                  false
                end
              end)

            {:error, _error} ->
              # Log an error if there is an issue decoding the quest loyalty data
              Logger.error("Error decoding quest loyalty data for quest #{badge.quest_id}")
          end
        end

        # Log the creation of a new transaction due to badge loyalty requirements
        Logger.info(
          "Creating a new transaction for badge #{badge.id} due to badge loyalty requirements"
        )

        # Create a new transaction for the badge and account
        Transactions.create_transaction_for_badge_account(badge.id, account.id)

        # Log the successful creation of a new transaction for the badge and account
        Logger.info("New transaction created for badge #{badge.id} and account #{account.id}")
      end)
    else
      # Log that no new transaction is needed or that insufficient time has passed since the last transaction
      Logger.info(
        "No new transaction needed or insufficient time has passed since the last transaction #{transaction_inserted_utc}"
      )
    end
  end

  def count_transactions_for_badge(account_id, badge_id) do
    Repo.aggregate(
      from(t in Transaction,
        where: t.account_id == ^account_id and not is_nil(t.badge_id) and t.badge_id == ^badge_id,
        select: count(t.id)
      ),
      :count,
      :id
    ) || 0
  end

  def count_points_for_badge(account_id, badge_id) do
    Repo.one(
      from(t in Transaction,
        where: t.account_id == ^account_id and not is_nil(t.badge_id) and t.badge_id == ^badge_id,
        select: coalesce(sum(t.lp_badge), 0)
      )
    ) || 0
  end

  def get_next_reward(account_id, badge_id, quest) do
    account = Repo.get!(Account, account_id)

    total_loyalty_points =
      Repo.one(
        from t in Transaction,
          where:
            t.account_id == ^account.id and not is_nil(t.badge_id) and t.badge_id == ^badge_id,
          select: coalesce(sum(t.lp_badge), 0)
      ) || 0

    with {:ok, reward_map} <- Jason.decode(quest.quest_loyalty) do
      reward_map
      |> Enum.map(fn {num, reward} -> {String.to_integer(num), reward} end)
      |> Enum.filter(fn {num, _reward} -> num > total_loyalty_points end)
      |> Enum.min_by(fn {num, _reward} -> num end, fn -> nil end)
      |> case do
        nil -> {:ok, nil}
        {next_reward_points, next_reward} -> {:ok, {next_reward_points, next_reward}}
      end
    else
      _ -> {:error, "Failed to decode quest loyalty data"}
    end
  end

  def get_next_scan_date(account_id, badge) do
    latest_transaction =
      Repo.one(
        from t in Transaction,
          where:
            t.account_id == ^account_id and not is_nil(t.badge_id) and t.badge_id == ^badge.id,
          order_by: [desc: t.inserted_at],
          limit: 1
      )

    transaction_inserted_utc =
      if latest_transaction do
        DateTime.from_naive!(latest_transaction.inserted_at, "Etc/UTC")
      else
        DateTime.utc_now()
      end

    next_scan_date = DateTime.add(transaction_inserted_utc, badge.cool_down_reset * 3600)
    next_scan_date
  end
end
