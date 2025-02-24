defmodule QuestApiV21Web.Account.AccountForgotPasswordLive do
  use QuestApiV21Web, :live_view

  alias QuestApiV21.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Forgot your password?
        <:subtitle>We'll send a password reset link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button
            phx-disable-with="Sending..."
            class="shadow-xl border-2 border-gold-100 w-full bg-contrast text-zinc-950"
          >
            Send password reset instructions
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-center text-sm mt-4">
        <.link href={~p"/accounts/register"}>Register</.link>
        | <.link href={~p"/accounts/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "account"))}
  end

  def handle_event("send_email", %{"account" => %{"email" => email}}, socket) do
    if account = Accounts.get_account_by_email(email) do
      Accounts.deliver_account_reset_password_instructions(
        account,
        fn token -> "https://questapp.io/accounts/reset_password/#{token}" end
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
