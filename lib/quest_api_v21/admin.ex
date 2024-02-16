defmodule QuestApiV21.Admin do
  @moduledoc """
  The Admin context.
  """

  import Ecto.Query, warn: false
  alias QuestApiV21.Repo

  alias QuestApiV21.Admin.{Superadmin, SuperadminToken, SuperadminNotifier}

  ## Database getters

  @doc """
  Gets a superadmin by email.

  ## Examples

      iex> get_superadmin_by_email("foo@example.com")
      %Superadmin{}

      iex> get_superadmin_by_email("unknown@example.com")
      nil

  """
  def get_superadmin_by_email(email) when is_binary(email) do
    Repo.get_by(Superadmin, email: email)
  end

  @doc """
  Gets a superadmin by email and password.

  ## Examples

      iex> get_superadmin_by_email_and_password("foo@example.com", "correct_password")
      %Superadmin{}

      iex> get_superadmin_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_superadmin_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    superadmin = Repo.get_by(Superadmin, email: email)
    if Superadmin.valid_password?(superadmin, password), do: superadmin
  end

  @doc """
  Gets a single superadmin.

  Raises `Ecto.NoResultsError` if the Superadmin does not exist.

  ## Examples

      iex> get_superadmin!(123)
      %Superadmin{}

      iex> get_superadmin!(456)
      ** (Ecto.NoResultsError)

  """
  def get_superadmin!(id), do: Repo.get!(Superadmin, id)

  ## Superadmin registration

  @doc """
  Registers a superadmin.

  ## Examples

      iex> register_superadmin(%{field: value})
      {:ok, %Superadmin{}}

      iex> register_superadmin(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_superadmin(attrs) do
    %Superadmin{}
    |> Superadmin.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking superadmin changes.

  ## Examples

      iex> change_superadmin_registration(superadmin)
      %Ecto.Changeset{data: %Superadmin{}}

  """
  def change_superadmin_registration(%Superadmin{} = superadmin, attrs \\ %{}) do
    Superadmin.registration_changeset(superadmin, attrs,
      hash_password: false,
      validate_email: false
    )
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the superadmin email.

  ## Examples

      iex> change_superadmin_email(superadmin)
      %Ecto.Changeset{data: %Superadmin{}}

  """
  def change_superadmin_email(superadmin, attrs \\ %{}) do
    Superadmin.email_changeset(superadmin, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_superadmin_email(superadmin, "valid password", %{email: ...})
      {:ok, %Superadmin{}}

      iex> apply_superadmin_email(superadmin, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_superadmin_email(superadmin, password, attrs) do
    superadmin
    |> Superadmin.email_changeset(attrs)
    |> Superadmin.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the superadmin email using the given token.

  If the token matches, the superadmin email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_superadmin_email(superadmin, token) do
    context = "change:#{superadmin.email}"

    with {:ok, query} <- SuperadminToken.verify_change_email_token_query(token, context),
         %SuperadminToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(superadmin_email_multi(superadmin, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp superadmin_email_multi(superadmin, email, context) do
    changeset =
      superadmin
      |> Superadmin.email_changeset(%{email: email})
      |> Superadmin.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:superadmin, changeset)
    |> Ecto.Multi.delete_all(
      :tokens,
      SuperadminToken.by_superadmin_and_contexts_query(superadmin, [context])
    )
  end

  @doc ~S"""
  Delivers the update email instructions to the given superadmin.

  ## Examples

      iex> deliver_superadmin_update_email_instructions(superadmin, current_email, &url(~p"/superadmin/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_superadmin_update_email_instructions(
        %Superadmin{} = superadmin,
        current_email,
        update_email_url_fun
      )
      when is_function(update_email_url_fun, 1) do
    {encoded_token, superadmin_token} =
      SuperadminToken.build_email_token(superadmin, "change:#{current_email}")

    Repo.insert!(superadmin_token)

    SuperadminNotifier.deliver_update_email_instructions(
      superadmin,
      update_email_url_fun.(encoded_token)
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the superadmin password.

  ## Examples

      iex> change_superadmin_password(superadmin)
      %Ecto.Changeset{data: %Superadmin{}}

  """
  def change_superadmin_password(superadmin, attrs \\ %{}) do
    Superadmin.password_changeset(superadmin, attrs, hash_password: false)
  end

  @doc """
  Updates the superadmin password.

  ## Examples

      iex> update_superadmin_password(superadmin, "valid password", %{password: ...})
      {:ok, %Superadmin{}}

      iex> update_superadmin_password(superadmin, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_superadmin_password(superadmin, password, attrs) do
    changeset =
      superadmin
      |> Superadmin.password_changeset(attrs)
      |> Superadmin.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:superadmin, changeset)
    |> Ecto.Multi.delete_all(
      :tokens,
      SuperadminToken.by_superadmin_and_contexts_query(superadmin, :all)
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{superadmin: superadmin}} -> {:ok, superadmin}
      {:error, :superadmin, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_superadmin_session_token(superadmin) do
    {token, superadmin_token} = SuperadminToken.build_session_token(superadmin)
    Repo.insert!(superadmin_token)
    token
  end

  @doc """
  Gets the superadmin with the given signed token.
  """
  def get_superadmin_by_session_token(token) do
    {:ok, query} = SuperadminToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_superadmin_session_token(token) do
    Repo.delete_all(SuperadminToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given superadmin.

  ## Examples

      iex> deliver_superadmin_confirmation_instructions(superadmin, &url(~p"/superadmin/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_superadmin_confirmation_instructions(confirmed_superadmin, &url(~p"/superadmin/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_superadmin_confirmation_instructions(
        %Superadmin{} = superadmin,
        confirmation_url_fun
      )
      when is_function(confirmation_url_fun, 1) do
    if superadmin.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, superadmin_token} = SuperadminToken.build_email_token(superadmin, "confirm")
      Repo.insert!(superadmin_token)

      SuperadminNotifier.deliver_confirmation_instructions(
        superadmin,
        confirmation_url_fun.(encoded_token)
      )
    end
  end

  @doc """
  Confirms a superadmin by the given token.

  If the token matches, the superadmin account is marked as confirmed
  and the token is deleted.
  """
  def confirm_superadmin(token) do
    with {:ok, query} <- SuperadminToken.verify_email_token_query(token, "confirm"),
         %Superadmin{} = superadmin <- Repo.one(query),
         {:ok, %{superadmin: superadmin}} <-
           Repo.transaction(confirm_superadmin_multi(superadmin)) do
      {:ok, superadmin}
    else
      _ -> :error
    end
  end

  defp confirm_superadmin_multi(superadmin) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:superadmin, Superadmin.confirm_changeset(superadmin))
    |> Ecto.Multi.delete_all(
      :tokens,
      SuperadminToken.by_superadmin_and_contexts_query(superadmin, ["confirm"])
    )
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given superadmin.

  ## Examples

      iex> deliver_superadmin_reset_password_instructions(superadmin, &url(~p"/superadmin/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_superadmin_reset_password_instructions(
        %Superadmin{} = superadmin,
        reset_password_url_fun
      )
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, superadmin_token} =
      SuperadminToken.build_email_token(superadmin, "reset_password")

    Repo.insert!(superadmin_token)

    SuperadminNotifier.deliver_reset_password_instructions(
      superadmin,
      reset_password_url_fun.(encoded_token)
    )
  end

  @doc """
  Gets the superadmin by reset password token.

  ## Examples

      iex> get_superadmin_by_reset_password_token("validtoken")
      %Superadmin{}

      iex> get_superadmin_by_reset_password_token("invalidtoken")
      nil

  """
  def get_superadmin_by_reset_password_token(token) do
    with {:ok, query} <- SuperadminToken.verify_email_token_query(token, "reset_password"),
         %Superadmin{} = superadmin <- Repo.one(query) do
      superadmin
    else
      _ -> nil
    end
  end

  @doc """
  Resets the superadmin password.

  ## Examples

      iex> reset_superadmin_password(superadmin, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Superadmin{}}

      iex> reset_superadmin_password(superadmin, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_superadmin_password(superadmin, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:superadmin, Superadmin.password_changeset(superadmin, attrs))
    |> Ecto.Multi.delete_all(
      :tokens,
      SuperadminToken.by_superadmin_and_contexts_query(superadmin, :all)
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{superadmin: superadmin}} -> {:ok, superadmin}
      {:error, :superadmin, changeset, _} -> {:error, changeset}
    end
  end
end
