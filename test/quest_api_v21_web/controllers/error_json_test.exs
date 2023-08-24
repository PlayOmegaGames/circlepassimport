defmodule QuestApiV21Web.ErrorJSONTest do
  use QuestApiV21Web.ConnCase, async: true

  test "renders 404" do
    assert QuestApiV21Web.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert QuestApiV21Web.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
