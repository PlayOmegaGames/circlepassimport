defmodule QuestApiV21.Repo.Migrations.AddedQrCodeUrl do
  use Ecto.Migration

  def change do
    alter table(:collectors) do
      add :qr_code_url, :string, size: 2000
    end
  end
end
