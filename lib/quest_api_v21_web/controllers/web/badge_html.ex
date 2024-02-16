defmodule QuestApiV21Web.Web.BadgeHTML do
  use QuestApiV21Web, :html
  import Phoenix.HTML.Tag

  embed_templates "badge_html/*"
end
