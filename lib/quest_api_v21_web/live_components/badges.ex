defmodule QuestApiV21Web.Badges do
  use Phoenix.LiveComponent




  def render(assigns) do
    IO.inspect(assigns.content.role)
    ~H"""

      <div>
        Role: <%= @content.role %>
      </div>
    """
  end
end
