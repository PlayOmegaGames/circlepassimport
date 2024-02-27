defmodule QuestApiV21.AccountquestsTest do
  use QuestApiV21.DataCase

  alias QuestApiV21.Accountquests

  describe "accountquest" do
    alias QuestApiV21.Accountquests.AccountQuest

    import QuestApiV21.AccountquestsFixtures

    @invalid_attrs %{badge_count: nil, loyalty_points: nil}

    test "list_accountquest/0 returns all accountquest" do
      account_quest = account_quest_fixture()
      assert Accountquests.list_accountquest() == [account_quest]
    end

    test "get_account_quest!/1 returns the account_quest with given id" do
      account_quest = account_quest_fixture()
      assert Accountquests.get_account_quest!(account_quest.id) == account_quest
    end

    test "create_account_quest/1 with valid data creates a account_quest" do
      valid_attrs = %{badge_count: 42, loyalty_points: 42}

      assert {:ok, %AccountQuest{} = account_quest} = Accountquests.create_account_quest(valid_attrs)
      assert account_quest.badge_count == 42
      assert account_quest.loyalty_points == 42
    end

    test "create_account_quest/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accountquests.create_account_quest(@invalid_attrs)
    end

    test "update_account_quest/2 with valid data updates the account_quest" do
      account_quest = account_quest_fixture()
      update_attrs = %{badge_count: 43, loyalty_points: 43}

      assert {:ok, %AccountQuest{} = account_quest} = Accountquests.update_account_quest(account_quest, update_attrs)
      assert account_quest.badge_count == 43
      assert account_quest.loyalty_points == 43
    end

    test "update_account_quest/2 with invalid data returns error changeset" do
      account_quest = account_quest_fixture()
      assert {:error, %Ecto.Changeset{}} = Accountquests.update_account_quest(account_quest, @invalid_attrs)
      assert account_quest == Accountquests.get_account_quest!(account_quest.id)
    end

    test "delete_account_quest/1 deletes the account_quest" do
      account_quest = account_quest_fixture()
      assert {:ok, %AccountQuest{}} = Accountquests.delete_account_quest(account_quest)
      assert_raise Ecto.NoResultsError, fn -> Accountquests.get_account_quest!(account_quest.id) end
    end

    test "change_account_quest/1 returns a account_quest changeset" do
      account_quest = account_quest_fixture()
      assert %Ecto.Changeset{} = Accountquests.change_account_quest(account_quest)
    end
  end
end
