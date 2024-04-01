defmodule QuestApiV21Web.SuperadminForgotPasswordLive do
  use QuestApiV21Web, :live_view

  alias QuestApiV21.Admin

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
          <.button phx-disable-with="Sending..." class="w-full">
            Send password reset instructions
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-center text-sm mt-4">
        <!--<.link href={~p"/superadmin/register"}>Register</.link>-->
        | <.link href={~p"/superadmin/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "superadmin"))}
  end

  def handle_event("send_email", %{"superadmin" => %{"email" => email}}, socket) do
    if superadmin = Admin.get_superadmin_by_email(email) do
      Admin.deliver_superadmin_reset_password_instructions(
        superadmin,
        &url(~p"/superadmin/reset_password/#{&1}")
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
