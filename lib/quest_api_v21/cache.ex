defmodule QuestApiV21.Cache do
  alias QuestApiV21.Repo
  alias QuestApiV21.Accounts.Account
  alias QuestApiV21.Badges.Badge
  alias QuestApiV21.Quests.Quest

  @moduledoc """
  A caching module for optimizing database interactions via ETS.
  """

  def start_link(_opts) do
    :ets.new(:accounts, [:named_table, :public, read_concurrency: true, write_concurrency: true])
    :ets.new(:badges, [:named_table, :public, read_concurrency: true])
    :ets.new(:quests, [:named_table, :public, read_concurrency: true])
    {:ok, %{}}
  end

  def get_account(account_id) do
    case :ets.lookup(:accounts, account_id) do
      [] ->
        account = Repo.get!(Account, account_id) |> Repo.preload([:badges, :quests])
        :ets.insert(:accounts, {account_id, account})
        account

      [{_, account}] ->
        account
    end
  end

  def update_account(account) do
    :ets.insert(:accounts, {account.id, account})
    # Here you might also need to update related cache entries if they depend on this account
  end

  def get_badge(badge_id) do
    case :ets.lookup(:badges, badge_id) do
      [] ->
        badge = Repo.get!(Badge, badge_id, preload: [:quest])
        :ets.insert(:badges, {badge_id, badge})
        badge

      [{_, badge}] ->
        badge
    end
  end

  def update_badge(badge) do
    :ets.insert(:badges, {badge.id, badge})
    # Potentially update or invalidate cached quests or accounts linked to this badge
  end

  def get_quest(quest_id) do
    case :ets.lookup(:quests, quest_id) do
      [] ->
        quest = Repo.get!(Quest, quest_id, preload: [:badges])
        :ets.insert(:quests, {quest_id, quest})
        quest

      [{_, quest}] ->
        quest
    end
  end

  def update_quest(quest) do
    :ets.insert(:quests, {quest.id, quest})
    # Potentially update or invalidate cached accounts or badges linked to this quest
  end
end
