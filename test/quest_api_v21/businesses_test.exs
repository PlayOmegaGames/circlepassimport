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
      organization = organization_fixture()
      assert Organizations.list_organizations() == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert Organizations.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Organization{} = organization} =
               Organizations.create_organization(valid_attrs)

      assert organization.name == "some name"
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = organization_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Organization{} = organization} =
               Organizations.update_organization(organization, update_attrs)

      assert organization.name == "some updated name"
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = organization_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Organizations.update_organization(organization, @invalid_attrs)

      assert organization == Organizations.get_organization!(organization.id)
    end

    test "delete_organization/1 deletes the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{}} = Organizations.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = Organizations.change_organization(organization)
    end
  end

  describe "many-to-many association between hosts and organizations" do
    test "associates a host with a organization" do
      # Create a host
      host_changeset =
        Host.changeset(%Host{}, %{
          name: "Host Name",
          email: "host@example.com",
          hashed_password: "password"
        })

      {:ok, host} = Repo.insert(host_changeset)

      # Create a organization
      organization_changeset =
        Organization.changeset(%Organization{}, %{name: "Organization Name"})

      {:ok, organization} = Repo.insert(organization_changeset)

      # Preload the hosts association for the organization
      organization = Repo.preload(organization, :hosts)

      # Associate the host with the organization
      intermediate_changeset = Ecto.Changeset.change(organization)

      updated_organization_changeset =
        Ecto.Changeset.put_assoc(intermediate_changeset, :hosts, [host])

      {:ok, updated_organization} = Repo.update(updated_organization_changeset)

      # Retrieve the organization with the associated hosts
      organization_with_hosts =
        Repo.get!(Organization, updated_organization.id) |> Repo.preload(:hosts)

      # Assert that the host was associated with the organization
      assert [^host] = organization_with_hosts.hosts

      # Print the organization record with the associated hosts to the console
      IO.inspect(organization_with_hosts, label: "Organization with Hosts")
    end
  end
end
