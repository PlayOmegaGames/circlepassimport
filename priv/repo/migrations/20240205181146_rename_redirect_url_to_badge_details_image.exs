defmodule QuestApiV21.Repo.Migrations.RenameRedirectUrlToBadgeDetailsImage do
  use Ecto.Migration

  def change do
    rename table("badge"), :redirect_url, to: :badge_details_image
    rename table("badge"), :image, to: :badge_image
    rename table("badge"), :unauthorized_url, to: :badge_redirect
  end
end
