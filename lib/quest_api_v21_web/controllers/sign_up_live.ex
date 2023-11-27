defmodule QuestApiV21Web.SignUpLive do
  use Phoenix.LiveView
  alias QuestApiV21.Accounts
  import Phoenix.HTML.Form
  import Phoenix.HTML
  import Phoenix.HTML.Tag
  require Logger

  @impl true
  def mount(_params, session, socket) do
    redirect_path = session["redirect_path"] || "/badges"
    {:ok, assign(socket, account: nil, user_params: %{}, errors: [], email_valid: false, password_strength: 0, crack_time: "N/A", form_valid: false, redirect_path: redirect_path, error_message: nil)}
  end


  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col justify-center items-center h-screen">

    <h1 class="text-center mb-2 text-2xl font-medium text-gray-600">
    Sign Up
    </h1>


    <!-- Form for user sign-up -->
    <%= form_for :user, "#", [phx_submit: :submit], fn f -> %>

      <div class="p-6 max-w-md mx-auto bg-white rounded-xl shadow-md">

      <%= if @error_message do %>
        <div class="alert alert-danger">
          <%= @error_message %>
        </div>
      <% end %>

      <div class="mb-4">
      <!-- Text input for name -->
        <%= text_input f, :name, value: @user_params[:name], placeholder: "Name", class: "w-full p-2 border rounded", phx_change: :validate_name %>
      </div>
        <div class="mb-4">
          <!-- Text input for email -->
          <%= email_input f, :email, value: @user_params[:email], placeholder: "Email", class: "w-full p-2 border rounded  #{if @email_valid, do: "focus:outline-none focus:ring-2 focus:ring-green-500 border-1 focus:border-green-500 border-green-500"}", phx_change: :validate_email %>
            <%= error_tag(@errors, :email) %>
        </div>
        <div class="mb-6">
          <!-- Text input for password -->
          <%= password_input f, :password, value: @user_params[:password], placeholder: "Password", class: "w-full p-2 border rounded #{password_input_class(@password_strength)}", phx_hook: "PasswordStrength" %>
          <!-- Password Strength Indicator -->
          <div class="mt-2">
            <div class="bg-gray-300 w-full rounded">
              <%= raw password_strength_indicator(@password_strength) %>
            </div>
            <!-- Crack Time Indicator -->
            <div class="mt-2 text-sm text-gray-600">
              Estimated crack time: <%= @crack_time %>
            </div>

        </div>

        </div>

        <div class="mt-5">
          <!-- Submit button -->
          <%= submit "Sign Up", class: "w-full py-2 px-4 bg-brand text-white rounded #{if !@form_valid, do: "opacity-50 cursor-not-allowed bg-brand", else: ""}", disabled: !@form_valid %>

        </div>
        <div class="w-full mt-12 flex justify-center">
          <a href="/sign_in" class="text-blue-500">Sign In</a>
        </div>

        </div>
    <% end %>
    </div>
    """
  end

  defp password_input_class(strength) do
    if strength == 100 do
      "focus:outline-none focus:ring-2 focus:ring-green-500 border-1 focus:border-green-500 border-green-500"
    else
      ""
    end
  end

  @impl true
  def handle_event("validate_email", %{"user" => %{"email" => email}}, socket) do
    email_valid = validate_email(email)
    user_params = Map.put(socket.assigns.user_params, :email, email)
    form_valid = form_valid?(email_valid, socket.assigns.password_strength, user_params[:name])
    {:noreply, assign(socket, user_params: user_params, email_valid: email_valid, form_valid: form_valid)}
  end

  @impl true
  def handle_event("password_strength", %{"password" => password, "strength" => strength, "crack_time" => crack_time}, socket) do
    password_class = if strength == 100, do: "focus:outline-none focus:ring-2 focus:ring-green-500 border-1 focus:border-green-500 border-green-500", else: ""
    user_params = Map.merge(socket.assigns.user_params, %{password: password})  # Updated line
    form_valid = form_valid?(socket.assigns.email_valid, strength, socket.assigns.user_params[:name])
    {:noreply, assign(socket, user_params: user_params, password_strength: strength, password_class: password_class, crack_time: crack_time, form_valid: form_valid)}
  end

  @impl true
  def handle_event("validate_name", %{"user" => %{"name" => name}}, socket) do
    user_params = Map.put(socket.assigns.user_params, :name, name)
    form_valid = form_valid?(socket.assigns.email_valid, socket.assigns.password_strength, name)
    {:noreply, assign(socket, user_params: user_params, form_valid: form_valid)}
  end

  def handle_event("submit", %{"user" => user_params}, socket) do
    case Accounts.create_account(user_params) do
      {:ok, account} ->
        Logger.info("Account created, emitting phx:account_created event")
       # Emit a test event
         push_event(socket, "phx:test_event", %{message: "Test event triggered"})

        # Retrieve the redirect path from the socket.assigns or set a default
        redirect_path = socket.assigns.redirect_path || "/badges"
        # Push an event with account_id and redirect_path
        push_event(socket, "phx:account_created", %{account_id: account.id, redirect_path: redirect_path})


        {:noreply, socket}

      {:error, changeset} ->
        error_message = extract_error_message(changeset)
        {:noreply, assign(socket, changeset: changeset, error_message: error_message)}
    end
  end



  defp extract_error_message(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    |> Enum.join(", ")
  end


  defp form_valid?(email_valid, password_strength, name) do
    email_valid and password_strength == 100 and name != nil and name != ""
  end

  defp error_tag(errors, field) do
    error = Keyword.get(errors, field)
    if error, do: content_tag(:span, error, class: "text-red-500")
  end

  defp password_strength_indicator(strength) do
    class = case strength do
      0 -> "bg-red-500"  # Weak
      25 -> "bg-red-500"  # Weak
      50 -> "bg-yellow-500"  # Medium
      75 -> "bg-yellow-500"  # Medium
      _ -> "bg-green-500"  # Strong
    end
    ~s(<div class="#{class} h-3" style="width: #{strength}%;"></div>)
  end

  defp validate_email(email) do
    Regex.match?(~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}$/i, email)
  end

end
