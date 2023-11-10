defmodule QuestApiV21.OrganizationsTest do
  use QuestApiV21.DataCase

  alias QuestApiV21.Organizations
  alias QuestApiV21.Repo
  alias QuestApiV21.Hosts.Host
  alias QuestApiV21.Organizations.Organization

  describe "organizations" do
    alias QuestApiV21.Organizations.Organization

    import QuestApiV21.OrganizationsFixtures

    @invalid_attrs %{name: nil}

    test "list_organizations/0 returns all organizations" do
      orgaization = orgaization_fixture()
      assert Organizations.list_organizations() == [orgaization]
    end

    test "get_orgaization!/1 returns the orgaization with given id" do
      orgaization = orgaization_fixture()
      assert Organizations.get_orgaization!(orgaization.id) == orgaization
    end

    test "create_orgaization/1 with valid data creates a orgaization" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Organization{} = orgaization} = Organizations.create_orgaization(valid_attrs)
      assert orgaization.name == "some name"
    end

    test "create_orgaization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_orgaization(@invalid_attrs)
    end

    test "update_orgaization/2 with valid data updates the orgaization" do
      orgaization = orgaization_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Organization{} = orgaization} = Organizations.update_orgaization(orgaization, update_attrs)
      assert orgaization.name == "some updated name"
    end

    test "update_orgaization/2 with invalid data returns error changeset" do
      orgaization = orgaization_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.update_orgaization(orgaization, @invalid_attrs)
      assert orgaization == Organizations.get_orgaization!(orgaization.id)
    end

    test "delete_orgaization/1 deletes the orgaization" do
      orgaization = orgaization_fixture()
      assert {:ok, %Organization{}} = Organizations.delete_orgaization(orgaization)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_orgaization!(orgaization.id) end
    end

    test "change_orgaization/1 returns a orgaization changeset" do
      orgaization = orgaization_fixture()
      assert %Ecto.Changeset{} = Organizations.change_orgaization(orgaization)
    end
  end

  describe "many-to-many association between hosts and organizations" do
    test "associates a host with a orgaization" do
      # Create a host
      host_changeset = Host.changeset(%Host{}, %{name: "Host Name", email: "host@example.com", hashed_password: "password"})
      {:ok, host} = Repo.insert(host_changeset)

      # Create a orgaization
      orgaization_changeset = Organization.changeset(%Organization{}, %{name: "Organization Name"})
      {:ok, orgaization} = Repo.insert(orgaization_changeset)

      # Preload the hosts association for the orgaization
      orgaization = Repo.preload(orgaization, :hosts)

      # Associate the host with the orgaization
      intermediate_changeset = Ecto.Changeset.change(orgaization)
      updated_orgaization_changeset = Ecto.Changeset.put_assoc(intermediate_changeset, :hosts, [host])
      {:ok, updated_orgaization} = Repo.update(updated_orgaization_changeset)

      # Retrieve the orgaization with the associated hosts
      orgaization_with_hosts = Repo.get!(Organization, updated_orgaization.id) |> Repo.preload(:hosts)

      # Assert that the host was associated with the orgaization
      assert [^host] = orgaization_with_hosts.hosts

      # Print the orgaization record with the associated hosts to the console
      IO.inspect(orgaization_with_hosts, label: "Organization with Hosts")
    end
  end
end
