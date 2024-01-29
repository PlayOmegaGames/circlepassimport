defmodule QuestApiV21Web.Layouts do
  use QuestApiV21Web, :html

  def calculate_class(request_path, url) do
    if request_path == url, do: "font-medium", else: "font-normal	"
  end

  def calculate_icon(request_path, url) do
    if request_path == url, do: "-solid", else: ""
  end
  embed_templates "layouts/*"
end
