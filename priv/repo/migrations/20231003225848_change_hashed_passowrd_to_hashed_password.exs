defmodule YourApp.Repo.Migrations.ChangeHashedPassowrdToHashedPassword do
  use Ecto.Migration

  def change do
    execute("ALTER TABLE accounts RENAME COLUMN hashed_passowrd TO hashed_password")
  end
end
