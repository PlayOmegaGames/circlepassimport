defmodule QuestApiV21.AdminTest do
  use QuestApiV21.DataCase

  alias QuestApiV21.Admin

  import QuestApiV21.AdminFixtures
  alias QuestApiV21.Admin.{Superadmin, SuperadminToken}

  describe "get_superadmin_by_email/1" do
    test "does not return the superadmin if the email does not exist" do
      refute Admin.get_superadmin_by_email("unknown@example.com")
    end

    test "returns the superadmin if the email exists" do
      %{id: id} = superadmin = superadmin_fixture()
      assert %Superadmin{id: ^id} = Admin.get_superadmin_by_email(superadmin.email)
    end
  end

  describe "get_superadmin_by_email_and_password/2" do
    test "does not return the superadmin if the email does not exist" do
      refute Admin.get_superadmin_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the superadmin if the password is not valid" do
      superadmin = superadmin_fixture()
      refute Admin.get_superadmin_by_email_and_password(superadmin.email, "invalid")
    end

    test "returns the superadmin if the email and password are valid" do
      %{id: id} = superadmin = superadmin_fixture()

      assert %Superadmin{id: ^id} =
               Admin.get_superadmin_by_email_and_password(superadmin.email, valid_superadmin_password())
    end
  end

  describe "get_superadmin!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Admin.get_superadmin!("11111111-1111-1111-1111-111111111111")
      end
    end

    test "returns the superadmin with the given id" do
      %{id: id} = superadmin = superadmin_fixture()
      assert %Superadmin{id: ^id} = Admin.get_superadmin!(superadmin.id)
    end
  end

  describe "register_superadmin/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Admin.register_superadmin(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Admin.register_superadmin(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Admin.register_superadmin(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = superadmin_fixture()
      {:error, changeset} = Admin.register_superadmin(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Admin.register_superadmin(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers superadmin with a hashed password" do
      email = unique_superadmin_email()
      {:ok, superadmin} = Admin.register_superadmin(valid_superadmin_attributes(email: email))
      assert superadmin.email == email
      assert is_binary(superadmin.hashed_password)
      assert is_nil(superadmin.confirmed_at)
      assert is_nil(superadmin.password)
    end
  end

  describe "change_superadmin_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Admin.change_superadmin_registration(%Superadmin{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_superadmin_email()
      password = valid_superadmin_password()

      changeset =
        Admin.change_superadmin_registration(
          %Superadmin{},
          valid_superadmin_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_superadmin_email/2" do
    test "returns a superadmin changeset" do
      assert %Ecto.Changeset{} = changeset = Admin.change_superadmin_email(%Superadmin{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_superadmin_email/3" do
    setup do
      %{superadmin: superadmin_fixture()}
    end

    test "requires email to change", %{superadmin: superadmin} do
      {:error, changeset} = Admin.apply_superadmin_email(superadmin, valid_superadmin_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{superadmin: superadmin} do
      {:error, changeset} =
        Admin.apply_superadmin_email(superadmin, valid_superadmin_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{superadmin: superadmin} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Admin.apply_superadmin_email(superadmin, valid_superadmin_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{superadmin: superadmin} do
      %{email: email} = superadmin_fixture()
      password = valid_superadmin_password()

      {:error, changeset} = Admin.apply_superadmin_email(superadmin, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{superadmin: superadmin} do
      {:error, changeset} =
        Admin.apply_superadmin_email(superadmin, "invalid", %{email: unique_superadmin_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{superadmin: superadmin} do
      email = unique_superadmin_email()
      {:ok, superadmin} = Admin.apply_superadmin_email(superadmin, valid_superadmin_password(), %{email: email})
      assert superadmin.email == email
      assert Admin.get_superadmin!(superadmin.id).email != email
    end
  end

  describe "deliver_superadmin_update_email_instructions/3" do
    setup do
      %{superadmin: superadmin_fixture()}
    end

    test "sends token through notification", %{superadmin: superadmin} do
      token =
        extract_superadmin_token(fn url ->
          Admin.deliver_superadmin_update_email_instructions(superadmin, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert superadmin_token = Repo.get_by(SuperadminToken, token: :crypto.hash(:sha256, token))
      assert superadmin_token.superadmin_id == superadmin.id
      assert superadmin_token.sent_to == superadmin.email
      assert superadmin_token.context == "change:current@example.com"
    end
  end

  describe "update_superadmin_email/2" do
    setup do
      superadmin = superadmin_fixture()
      email = unique_superadmin_email()

      token =
        extract_superadmin_token(fn url ->
          Admin.deliver_superadmin_update_email_instructions(%{superadmin | email: email}, superadmin.email, url)
        end)

      %{superadmin: superadmin, token: token, email: email}
    end

    test "updates the email with a valid token", %{superadmin: superadmin, token: token, email: email} do
      assert Admin.update_superadmin_email(superadmin, token) == :ok
      changed_superadmin = Repo.get!(Superadmin, superadmin.id)
      assert changed_superadmin.email != superadmin.email
      assert changed_superadmin.email == email
      assert changed_superadmin.confirmed_at
      assert changed_superadmin.confirmed_at != superadmin.confirmed_at
      refute Repo.get_by(SuperadminToken, superadmin_id: superadmin.id)
    end

    test "does not update email with invalid token", %{superadmin: superadmin} do
      assert Admin.update_superadmin_email(superadmin, "oops") == :error
      assert Repo.get!(Superadmin, superadmin.id).email == superadmin.email
      assert Repo.get_by(SuperadminToken, superadmin_id: superadmin.id)
    end

    test "does not update email if superadmin email changed", %{superadmin: superadmin, token: token} do
      assert Admin.update_superadmin_email(%{superadmin | email: "current@example.com"}, token) == :error
      assert Repo.get!(Superadmin, superadmin.id).email == superadmin.email
      assert Repo.get_by(SuperadminToken, superadmin_id: superadmin.id)
    end

    test "does not update email if token expired", %{superadmin: superadmin, token: token} do
      {1, nil} = Repo.update_all(SuperadminToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Admin.update_superadmin_email(superadmin, token) == :error
      assert Repo.get!(Superadmin, superadmin.id).email == superadmin.email
      assert Repo.get_by(SuperadminToken, superadmin_id: superadmin.id)
    end
  end

  describe "change_superadmin_password/2" do
    test "returns a superadmin changeset" do
      assert %Ecto.Changeset{} = changeset = Admin.change_superadmin_password(%Superadmin{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Admin.change_superadmin_password(%Superadmin{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_superadmin_password/3" do
    setup do
      %{superadmin: superadmin_fixture()}
    end

    test "validates password", %{superadmin: superadmin} do
      {:error, changeset} =
        Admin.update_superadmin_password(superadmin, valid_superadmin_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{superadmin: superadmin} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Admin.update_superadmin_password(superadmin, valid_superadmin_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{superadmin: superadmin} do
      {:error, changeset} =
        Admin.update_superadmin_password(superadmin, "invalid", %{password: valid_superadmin_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{superadmin: superadmin} do
      {:ok, superadmin} =
        Admin.update_superadmin_password(superadmin, valid_superadmin_password(), %{
          password: "new valid password"
        })

      assert is_nil(superadmin.password)
      assert Admin.get_superadmin_by_email_and_password(superadmin.email, "new valid password")
    end

    test "deletes all tokens for the given superadmin", %{superadmin: superadmin} do
      _ = Admin.generate_superadmin_session_token(superadmin)

      {:ok, _} =
        Admin.update_superadmin_password(superadmin, valid_superadmin_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(SuperadminToken, superadmin_id: superadmin.id)
    end
  end

  describe "generate_superadmin_session_token/1" do
    setup do
      %{superadmin: superadmin_fixture()}
    end

    test "generates a token", %{superadmin: superadmin} do
      token = Admin.generate_superadmin_session_token(superadmin)
      assert superadmin_token = Repo.get_by(SuperadminToken, token: token)
      assert superadmin_token.context == "session"

      # Creating the same token for another superadmin should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%SuperadminToken{
          token: superadmin_token.token,
          superadmin_id: superadmin_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_superadmin_by_session_token/1" do
    setup do
      superadmin = superadmin_fixture()
      token = Admin.generate_superadmin_session_token(superadmin)
      %{superadmin: superadmin, token: token}
    end

    test "returns superadmin by token", %{superadmin: superadmin, token: token} do
      assert session_superadmin = Admin.get_superadmin_by_session_token(token)
      assert session_superadmin.id == superadmin.id
    end

    test "does not return superadmin for invalid token" do
      refute Admin.get_superadmin_by_session_token("oops")
    end

    test "does not return superadmin for expired token", %{token: token} do
      {1, nil} = Repo.update_all(SuperadminToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Admin.get_superadmin_by_session_token(token)
    end
  end

  describe "delete_superadmin_session_token/1" do
    test "deletes the token" do
      superadmin = superadmin_fixture()
      token = Admin.generate_superadmin_session_token(superadmin)
      assert Admin.delete_superadmin_session_token(token) == :ok
      refute Admin.get_superadmin_by_session_token(token)
    end
  end

  describe "deliver_superadmin_confirmation_instructions/2" do
    setup do
      %{superadmin: superadmin_fixture()}
    end

    test "sends token through notification", %{superadmin: superadmin} do
      token =
        extract_superadmin_token(fn url ->
          Admin.deliver_superadmin_confirmation_instructions(superadmin, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert superadmin_token = Repo.get_by(SuperadminToken, token: :crypto.hash(:sha256, token))
      assert superadmin_token.superadmin_id == superadmin.id
      assert superadmin_token.sent_to == superadmin.email
      assert superadmin_token.context == "confirm"
    end
  end

  describe "confirm_superadmin/1" do
    setup do
      superadmin = superadmin_fixture()

      token =
        extract_superadmin_token(fn url ->
          Admin.deliver_superadmin_confirmation_instructions(superadmin, url)
        end)

      %{superadmin: superadmin, token: token}
    end

    test "confirms the email with a valid token", %{superadmin: superadmin, token: token} do
      assert {:ok, confirmed_superadmin} = Admin.confirm_superadmin(token)
      assert confirmed_superadmin.confirmed_at
      assert confirmed_superadmin.confirmed_at != superadmin.confirmed_at
      assert Repo.get!(Superadmin, superadmin.id).confirmed_at
      refute Repo.get_by(SuperadminToken, superadmin_id: superadmin.id)
    end

    test "does not confirm with invalid token", %{superadmin: superadmin} do
      assert Admin.confirm_superadmin("oops") == :error
      refute Repo.get!(Superadmin, superadmin.id).confirmed_at
      assert Repo.get_by(SuperadminToken, superadmin_id: superadmin.id)
    end

    test "does not confirm email if token expired", %{superadmin: superadmin, token: token} do
      {1, nil} = Repo.update_all(SuperadminToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Admin.confirm_superadmin(token) == :error
      refute Repo.get!(Superadmin, superadmin.id).confirmed_at
      assert Repo.get_by(SuperadminToken, superadmin_id: superadmin.id)
    end
  end

  describe "deliver_superadmin_reset_password_instructions/2" do
    setup do
      %{superadmin: superadmin_fixture()}
    end

    test "sends token through notification", %{superadmin: superadmin} do
      token =
        extract_superadmin_token(fn url ->
          Admin.deliver_superadmin_reset_password_instructions(superadmin, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert superadmin_token = Repo.get_by(SuperadminToken, token: :crypto.hash(:sha256, token))
      assert superadmin_token.superadmin_id == superadmin.id
      assert superadmin_token.sent_to == superadmin.email
      assert superadmin_token.context == "reset_password"
    end
  end

  describe "get_superadmin_by_reset_password_token/1" do
    setup do
      superadmin = superadmin_fixture()

      token =
        extract_superadmin_token(fn url ->
          Admin.deliver_superadmin_reset_password_instructions(superadmin, url)
        end)

      %{superadmin: superadmin, token: token}
    end

    test "returns the superadmin with valid token", %{superadmin: %{id: id}, token: token} do
      assert %Superadmin{id: ^id} = Admin.get_superadmin_by_reset_password_token(token)
      assert Repo.get_by(SuperadminToken, superadmin_id: id)
    end

    test "does not return the superadmin with invalid token", %{superadmin: superadmin} do
      refute Admin.get_superadmin_by_reset_password_token("oops")
      assert Repo.get_by(SuperadminToken, superadmin_id: superadmin.id)
    end

    test "does not return the superadmin if token expired", %{superadmin: superadmin, token: token} do
      {1, nil} = Repo.update_all(SuperadminToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Admin.get_superadmin_by_reset_password_token(token)
      assert Repo.get_by(SuperadminToken, superadmin_id: superadmin.id)
    end
  end

  describe "reset_superadmin_password/2" do
    setup do
      %{superadmin: superadmin_fixture()}
    end

    test "validates password", %{superadmin: superadmin} do
      {:error, changeset} =
        Admin.reset_superadmin_password(superadmin, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{superadmin: superadmin} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Admin.reset_superadmin_password(superadmin, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{superadmin: superadmin} do
      {:ok, updated_superadmin} = Admin.reset_superadmin_password(superadmin, %{password: "new valid password"})
      assert is_nil(updated_superadmin.password)
      assert Admin.get_superadmin_by_email_and_password(superadmin.email, "new valid password")
    end

    test "deletes all tokens for the given superadmin", %{superadmin: superadmin} do
      _ = Admin.generate_superadmin_session_token(superadmin)
      {:ok, _} = Admin.reset_superadmin_password(superadmin, %{password: "new valid password"})
      refute Repo.get_by(SuperadminToken, superadmin_id: superadmin.id)
    end
  end

  describe "inspect/2 for the Superadmin module" do
    test "does not include password" do
      refute inspect(%Superadmin{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
