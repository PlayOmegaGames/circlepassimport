defmodule QuestApiV21.Collection_PointsTest do
  use QuestApiV21.DataCase

  alias QuestApiV21.Collection_Points

  describe "collection_point" do
    alias QuestApiV21.Collection_Points.Collection_Point

    import QuestApiV21.Collection_PointsFixtures

    @invalid_attrs %{badge_description: nil, image: nil, name: nil, redirect_url: nil, scans: nil}

    test "list_collection_point/0 returns all collection_point" do
      collection__point = collection__point_fixture()
      assert Collection_Points.list_collection_point() == [collection__point]
    end

    test "get_collection__point!/1 returns the collection__point with given id" do
      collection__point = collection__point_fixture()
      assert Collection_Points.get_collection__point!(collection__point.id) == collection__point
    end

    test "create_collection__point/1 with valid data creates a collection__point" do
      valid_attrs = %{badge_description: "some badge_description", image: "some image", name: "some name", redirect_url: "some redirect_url", scans: 42}

      assert {:ok, %Collection_Point{} = collection__point} = Collection_Points.create_collection__point(valid_attrs)
      assert collection__point.badge_description == "some badge_description"
      assert collection__point.image == "some image"
      assert collection__point.name == "some name"
      assert collection__point.redirect_url == "some redirect_url"
      assert collection__point.scans == 42
    end

    test "create_collection__point/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Collection_Points.create_collection__point(@invalid_attrs)
    end

    test "update_collection__point/2 with valid data updates the collection__point" do
      collection__point = collection__point_fixture()
      update_attrs = %{badge_description: "some updated badge_description", image: "some updated image", name: "some updated name", redirect_url: "some updated redirect_url", scans: 43}

      assert {:ok, %Collection_Point{} = collection__point} = Collection_Points.update_collection__point(collection__point, update_attrs)
      assert collection__point.badge_description == "some updated badge_description"
      assert collection__point.image == "some updated image"
      assert collection__point.name == "some updated name"
      assert collection__point.redirect_url == "some updated redirect_url"
      assert collection__point.scans == 43
    end

    test "update_collection__point/2 with invalid data returns error changeset" do
      collection__point = collection__point_fixture()
      assert {:error, %Ecto.Changeset{}} = Collection_Points.update_collection__point(collection__point, @invalid_attrs)
      assert collection__point == Collection_Points.get_collection__point!(collection__point.id)
    end

    test "delete_collection__point/1 deletes the collection__point" do
      collection__point = collection__point_fixture()
      assert {:ok, %Collection_Point{}} = Collection_Points.delete_collection__point(collection__point)
      assert_raise Ecto.NoResultsError, fn -> Collection_Points.get_collection__point!(collection__point.id) end
    end

    test "change_collection__point/1 returns a collection__point changeset" do
      collection__point = collection__point_fixture()
      assert %Ecto.Changeset{} = Collection_Points.change_collection__point(collection__point)
    end
  end
end
