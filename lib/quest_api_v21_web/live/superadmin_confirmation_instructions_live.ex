defmodule QuestApiV21Web.SuperadminConfirmationInstructionsLive do
  use QuestApiV21Web, :live_view

  alias QuestApiV21.Admin

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        No confirmation instructions received?
        <:subtitle>We'll send a new confirmation link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            Resend confirmation instructions
          </.button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/superadmin/register"}>Register</.link>
        | <.link href={~p"/superadmin/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "superadmin"))}
  end

  def handle_event("send_instructions", %{"superadmin" => %{"email" => email}}, socket) do
    if superadmin = Admin.get_superadmin_by_email(email) do
      Admin.deliver_superadmin_confirmation_instructions(
        superadmin,
        &url(~p"/superadmin/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
