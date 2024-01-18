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
    {:ok, assign(socket,
        account: nil,
        user_params: %{},
        errors: [],
        email_valid: false,
        password_strength: 0,
        crack_time: "N/A",
        form_valid: false,
        redirect_path: redirect_path,
        error_message: nil,
        body_class: "bg-gradient-to-b from-purple-400 to-brand h-screen bg-no-repeat"
        )}
  end

  @impl true
  def render(assigns) do
    ~H"""

    <div class="w-full flex justify-center mt-8">
      <a href="/sign_in" class="text-white absolute">Have an account? - <span class="underline underline-offset-1">sign in</span></a>
    </div>

    <img class="mx-auto mt-8 h-32 w-auto" src="/images/WhiteQuestLogo.svg" alt="Quest Logo">

    <div class="flex flex-col items-center justify-content-center">


    <!-- Form for user sign-up -->
    <%= form_for :user, "#", [
      id: "signup-form",
      class: "w-11/12 max-w-sm",
      phx_hook: "FormSubmit",
      data: [redirect_path: @redirect_path]], fn f -> %>

      <div class="px-8 pb-8  pt-6 mt-8 bg-transparent max-w-sm w-80 rounded-xl shadow-md mx-auto">

        <h1 class="text-center mb-6 text-2xl font-medium text-white">
          Sign Up
        </h1>

      <%= if @error_message do %>
        <div class="alert alert-danger">
          <%= @error_message %>
        </div>
      <% end %>

      <div class="mb-4">
      <!-- Text input for name -->
        <%= text_input f, :name, value: @user_params[:name], placeholder: "Name",
            class: "w-full pl-4 p-3 border rounded-full", phx_change: :validate_name %>
      </div>
        <div class="mb-4">
          <!-- Text input for email -->
          <%= email_input f, :email, value: @user_params[:email], placeholder: "Email",
              class: "w-full pl-4 p-3 border rounded-full  #{if @email_valid, do: "focus:outline-none focus:ring-2 focus:ring-green-500 border-1 focus:border-green-500 border-green-500"}", phx_change: :validate_email %>
            <%= error_tag(@errors, :email) %>
        </div>
        <div class="mb-6">
          <!-- Text input for password -->
          <%= password_input f, :password, value: @user_params[:password], placeholder: "Password",
              class: "w-full pl-4 p-3 border rounded-full #{password_input_class(@password_strength)}", phx_hook: "PasswordStrength" %>
          <!-- Password Strength Indicator -->
          <div class="mt-2">
            <div class="bg-gray-300 w-11/12 rounded-full ml-3">
              <%= raw password_strength_indicator(@password_strength) %>
            </div>
            <!-- Crack Time Indicator -->
            <div class="mt-2 text-sm text-gray-100 ml-4">
              Estimated crack time: <%= @crack_time %>
            </div>

        </div>

        </div>

        <div class="mt-3">
          <!-- Submit button -->
          <%= submit "Sign Up",
          class: "border-2 border-brand text-lg w-full py-2 px-4 bg-white font-medium text-slate-900 rounded-lg
                  #{if !@form_valid, do: "opacity-50 cursor-not-allowed bg-brand ", else: "white-glow drop-shadow-2xl"}", disabled: !@form_valid %>

        </div>

        </div>
    <% end %>
    </div>
    """
  end

  defp password_input_class(strength) do
    if strength >= 50 do
      "shadow-inner focus:outline-none focus:ring-2 focus:ring-green-500 border-1 focus:border-green-500 border-green-500"
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

  @impl true
  def handle_event("submit", %{"user" => user_params}, socket) do
    case Accounts.create_account(user_params) do
      {:ok, _account} ->
        Logger.info("Account created, redirecting to #{socket.assigns.redirect_path}")

        # Perform a redirect after successful account creation
        push_redirect(socket, to: socket.assigns.redirect_path)

      {:noreply, socket}

      {:error, changeset} ->
        error_message = extract_error_message(changeset)
        # Assign the changeset errors to the socket for display
      {:noreply, assign(socket, user_params: user_params, errors: changeset.errors, error_message: error_message)}
    end
  end

  defp extract_error_message(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    |> Enum.join(", ")
  end

  defp form_valid?(email_valid, password_strength, name) do
    email_valid and password_strength >= 50 and name != nil and name != ""
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
    ~s(<div class="#{class} rounded-full h-3" style="width: #{strength}%;"></div>)
  end

  defp validate_email(email) do
    Regex.match?(~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}$/i, email)
  end

end
