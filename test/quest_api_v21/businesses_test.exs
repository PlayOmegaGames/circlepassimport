defmodule QuestApiV21.BusinessesTest do
  use QuestApiV21.DataCase

  alias QuestApiV21.Businesses
  alias QuestApiV21.Repo
  alias QuestApiV21.Hosts.Host
  alias QuestApiV21.Businesses.Business

  describe "businesses" do
    alias QuestApiV21.Businesses.Business

    import QuestApiV21.BusinessesFixtures

    @invalid_attrs %{name: nil}

    test "list_businesses/0 returns all businesses" do
      business = business_fixture()
      assert Businesses.list_businesses() == [business]
    end

    test "get_business!/1 returns the business with given id" do
      business = business_fixture()
      assert Businesses.get_business!(business.id) == business
    end

    test "create_business/1 with valid data creates a business" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Business{} = business} = Businesses.create_business(valid_attrs)
      assert business.name == "some name"
    end

    test "create_business/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Businesses.create_business(@invalid_attrs)
    end

    test "update_business/2 with valid data updates the business" do
      business = business_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Business{} = business} = Businesses.update_business(business, update_attrs)
      assert business.name == "some updated name"
    end

    test "update_business/2 with invalid data returns error changeset" do
      business = business_fixture()
      assert {:error, %Ecto.Changeset{}} = Businesses.update_business(business, @invalid_attrs)
      assert business == Businesses.get_business!(business.id)
    end

    test "delete_business/1 deletes the business" do
      business = business_fixture()
      assert {:ok, %Business{}} = Businesses.delete_business(business)
      assert_raise Ecto.NoResultsError, fn -> Businesses.get_business!(business.id) end
    end

    test "change_business/1 returns a business changeset" do
      business = business_fixture()
      assert %Ecto.Changeset{} = Businesses.change_business(business)
    end
  end

  describe "many-to-many association between hosts and businesses" do
    test "associates a host with a business" do
      # Create a host
      host_changeset = Host.changeset(%Host{}, %{name: "Host Name", email: "host@example.com", hashed_password: "password"})
      {:ok, host} = Repo.insert(host_changeset)

      # Create a business
      business_changeset = Business.changeset(%Business{}, %{name: "Business Name"})
      {:ok, business} = Repo.insert(business_changeset)

      # Preload the hosts association for the business
      business = Repo.preload(business, :hosts)

      # Associate the host with the business
      intermediate_changeset = Ecto.Changeset.change(business)
      updated_business_changeset = Ecto.Changeset.put_assoc(intermediate_changeset, :hosts, [host])
      {:ok, updated_business} = Repo.update(updated_business_changeset)

      # Retrieve the business with the associated hosts
      business_with_hosts = Repo.get!(Business, updated_business.id) |> Repo.preload(:hosts)

      # Assert that the host was associated with the business
      assert [^host] = business_with_hosts.hosts

      # Print the business record with the associated hosts to the console
      IO.inspect(business_with_hosts, label: "Business with Hosts")
    end
  end
end
