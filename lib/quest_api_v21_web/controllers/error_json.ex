defmodule QuestApiV21Web.ErrorJSON do
  # Example of customizing specific error responses
  def render("404.json", _assigns) do
    %{errors: %{detail: "Resource not found"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal Server Error"}}
  end

  # Custom error for handling badge or quest association errors
  def render("association_error.json", %{message: message}) do
    %{errors: %{detail: "Association Error", message: message}}
  end

  # Default handler for specific error with message and additional errors
  def render("error.json", %{message: message, errors: errors}) do
    %{message: message, errors: errors}
  end

  # General handler for unspecified errors
  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
