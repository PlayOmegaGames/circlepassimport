defmodule QuestApiV21.AdminFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuestApiV21.Admin` context.
  """

  def unique_superadmin_email, do: "superadmin#{System.unique_integer()}@example.com"
  def valid_superadmin_password, do: "hello world!"

  def valid_superadmin_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_superadmin_email(),
      password: valid_superadmin_password()
    })
  end

  def superadmin_fixture(attrs \\ %{}) do
    {:ok, superadmin} =
      attrs
      |> valid_superadmin_attributes()
      |> QuestApiV21.Admin.register_superadmin()

    superadmin
  end

  def extract_superadmin_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
