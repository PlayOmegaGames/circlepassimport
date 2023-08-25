defmodule QuestApiV21.CollectorsTest do
  use QuestApiV21.DataCase

  alias QuestApiV21.Collectors

  describe "collectors" do
    alias QuestApiV21.Collectors.Collector

    import QuestApiV21.CollectorsFixtures

    @invalid_attrs %{coordinates: nil, height: nil, name: nil}

    test "list_collectors/0 returns all collectors" do
      collector = collector_fixture()
      assert Collectors.list_collectors() == [collector]
    end

    test "get_collector!/1 returns the collector with given id" do
      collector = collector_fixture()
      assert Collectors.get_collector!(collector.id) == collector
    end

    test "create_collector/1 with valid data creates a collector" do
      valid_attrs = %{coordinates: "some coordinates", height: "some height", name: "some name"}

      assert {:ok, %Collector{} = collector} = Collectors.create_collector(valid_attrs)
      assert collector.coordinates == "some coordinates"
      assert collector.height == "some height"
      assert collector.name == "some name"
    end

    test "create_collector/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Collectors.create_collector(@invalid_attrs)
    end

    test "update_collector/2 with valid data updates the collector" do
      collector = collector_fixture()
      update_attrs = %{coordinates: "some updated coordinates", height: "some updated height", name: "some updated name"}

      assert {:ok, %Collector{} = collector} = Collectors.update_collector(collector, update_attrs)
      assert collector.coordinates == "some updated coordinates"
      assert collector.height == "some updated height"
      assert collector.name == "some updated name"
    end

    test "update_collector/2 with invalid data returns error changeset" do
      collector = collector_fixture()
      assert {:error, %Ecto.Changeset{}} = Collectors.update_collector(collector, @invalid_attrs)
      assert collector == Collectors.get_collector!(collector.id)
    end

    test "delete_collector/1 deletes the collector" do
      collector = collector_fixture()
      assert {:ok, %Collector{}} = Collectors.delete_collector(collector)
      assert_raise Ecto.NoResultsError, fn -> Collectors.get_collector!(collector.id) end
    end

    test "change_collector/1 returns a collector changeset" do
      collector = collector_fixture()
      assert %Ecto.Changeset{} = Collectors.change_collector(collector)
    end
  end
end
