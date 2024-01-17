defmodule QuestApiV21Web.Layouts do
  use QuestApiV21Web, :html

  def calculate_class(request_path, url) do
    if request_path == url, do: "text-violet-700", else: "text-slate-700"
  end

  embed_templates "layouts/*"
end
