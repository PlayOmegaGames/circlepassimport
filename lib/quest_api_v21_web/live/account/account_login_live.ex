defmodule QuestApiV21Web.Account.AccountLoginLive do
  use QuestApiV21Web, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Sign In
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/accounts/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/accounts/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/accounts/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button
            phx-disable-with="Signing in..."
            class="shadow-xl border-2 border-gold-100 w-full bg-contrast text-zinc-950"
          >
            Sign in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    <p class="text-center text-black my-4">or</p>
    <div class="mb-4 flex justify-center">
      <a href="/auth/google">
        <.google />
      </a>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "account")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end