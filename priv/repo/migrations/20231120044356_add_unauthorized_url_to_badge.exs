defmodule QuestApiV21.Repo.Migrations.AddUnauthorizedUrlToBadge do
  use Ecto.Migration

  def change do
    alter table(:badge) do
      add :unauthorized_url, :string  # Add the unauthorized_url field
    end
  end
end
