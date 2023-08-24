defmodule QuestApiV21.Repo.Migrations.CreateCollectionPoint do
  use Ecto.Migration

  def change do
    create table(:collection_point, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :image, :string
      add :scans, :integer
      add :redirect_url, :string
      add :badge_description, :text

      timestamps()
    end
  end
end
