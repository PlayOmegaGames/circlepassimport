defmodule QuestApiV21Web.LiveComponents.CompTest do
  # In Phoenix apps, the line is typically: use MyAppWeb, :html
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div>
    <p>Hello, <%= @name %>!</p>
    <p>Your user ID </p>
    </div>
    """
  end
end
