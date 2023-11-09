defmodule QuestApiV21.BadgesTest do
  use QuestApiV21.DataCase

  alias QuestApiV21.Badges

  describe "badge" do
    alias QuestApiV21.Badges.Badge

    import QuestApiV21.BadgesFixtures

    @invalid_attrs %{badge_description: nil, image: nil, name: nil, redirect_url: nil, scans: nil}

    test "list_badge/0 returns all badge" do
      badge = badge_fixture()
      assert Badges.list_badge() == [badge]
    end

    test "get_badge!/1 returns the badge with given id" do
      badge = badge_fixture()
      assert Badges.get_badge!(badge.id) == badge
    end

    test "create_badge/1 with valid data creates a badge" do
      valid_attrs = %{badge_description: "some badge_description", image: "some image", name: "some name", redirect_url: "some redirect_url", scans: 42}

      assert {:ok, %Badge{} = badge} = Badges.create_badge(valid_attrs)
      assert badge.badge_description == "some badge_description"
      assert badge.image == "some image"
      assert badge.name == "some name"
      assert badge.redirect_url == "some redirect_url"
      assert badge.scans == 42
    end

    test "create_badge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Badges.create_badge(@invalid_attrs)
    end

    test "update_badge/2 with valid data updates the badge" do
      badge = badge_fixture()
      update_attrs = %{badge_description: "some updated badge_description", image: "some updated image", name: "some updated name", redirect_url: "some updated redirect_url", scans: 43}

      assert {:ok, %Badge{} = badge} = Badges.update_badge(badge, update_attrs)
      assert badge.badge_description == "some updated badge_description"
      assert badge.image == "some updated image"
      assert badge.name == "some updated name"
      assert badge.redirect_url == "some updated redirect_url"
      assert badge.scans == 43
    end

    test "update_badge/2 with invalid data returns error changeset" do
      badge = badge_fixture()
      assert {:error, %Ecto.Changeset{}} = Badges.update_badge(badge, @invalid_attrs)
      assert badge == Badges.get_badge!(badge.id)
    end

    test "delete_badge/1 deletes the badge" do
      badge = badge_fixture()
      assert {:ok, %Badge{}} = Badges.delete_badge(badge)
      assert_raise Ecto.NoResultsError, fn -> Badges.get_badge!(badge.id) end
    end

    test "change_badge/1 returns a badge changeset" do
      badge = badge_fixture()
      assert %Ecto.Changeset{} = Badges.change_badge(badge)
    end
  end
end
