defmodule QuestApiV21.QuestsTest do
  use QuestApiV21.DataCase

  alias QuestApiV21.Quests

  describe "quests" do
    alias QuestApiV21.Quests.Quest

    import QuestApiV21.QuestsFixtures

    @invalid_attrs %{
      address: nil,
      "end-date": nil,
      name: nil,
      "quest-type": nil,
      redemption: nil,
      reward: nil,
      transactions: nil,
      "start-date": nil
    }

    test "list_quests/0 returns all quests" do
      quest = quest_fixture()
      assert Quests.list_quests() == [quest]
    end

    test "get_quest!/1 returns the quest with given id" do
      quest = quest_fixture()
      assert Quests.get_quest!(quest.id) == quest
    end

    test "create_quest/1 with valid data creates a quest" do
      valid_attrs = %{
        address: "some address",
        "end-date": ~D[2023-08-23],
        name: "some name",
        "quest-type": "some quest-type",
        redemption: "some redemption",
        reward: "some reward",
        transactions: 42,
        "start-date": ~D[2023-08-23]
      }

      assert {:ok, %Quest{} = quest} = Quests.create_quest(valid_attrs)
      assert quest.address == "some address"
      assert quest.end_date == ~D[2023-08-23]
      assert quest.name == "some name"
      assert quest.quest_type == "some quest-type"
      assert quest.redemption == "some redemption"
      assert quest.reward == "some reward"
      assert quest.transactions == 42
      assert quest.start_date == ~D[2023-08-23]
    end

    test "create_quest/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quests.create_quest(@invalid_attrs)
    end

    test "update_quest/2 with valid data updates the quest" do
      quest = quest_fixture()

      update_attrs = %{
        address: "some updated address",
        "end-date": ~D[2023-08-24],
        name: "some updated name",
        "quest-type": "some updated quest-type",
        redemption: "some updated redemption",
        reward: "some updated reward",
        transactions: 43,
        "start-date": ~D[2023-08-24]
      }

      assert {:ok, %Quest{} = quest} = Quests.update_quest(quest, update_attrs)
      assert quest.address == "some updated address"
      assert quest.end_date == ~D[2023-08-24]
      assert quest.name == "some updated name"
      assert quest.quest_type == "some updated quest-type"
      assert quest.redemption == "some updated redemption"
      assert quest.reward == "some updated reward"
      assert quest.transactions == 43
      assert quest.start_date == ~D[2023-08-24]
    end

    test "update_quest/2 with invalid data returns error changeset" do
      quest = quest_fixture()
      assert {:error, %Ecto.Changeset{}} = Quests.update_quest(quest, @invalid_attrs)
      assert quest == Quests.get_quest!(quest.id)
    end

    test "delete_quest/1 deletes the quest" do
      quest = quest_fixture()
      assert {:ok, %Quest{}} = Quests.delete_quest(quest)
      assert_raise Ecto.NoResultsError, fn -> Quests.get_quest!(quest.id) end
    end

    test "change_quest/1 returns a quest changeset" do
      quest = quest_fixture()
      assert %Ecto.Changeset{} = Quests.change_quest(quest)
    end
  end
end
