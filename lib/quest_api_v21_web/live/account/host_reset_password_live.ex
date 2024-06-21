defmodule QuestApiV21Web.Account.HostResetPasswordLive do
  use QuestApiV21Web, :live_view

  alias QuestApiV21.Hosts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <div phx-hook="ExternalRedirect" id="external-redirect"></div>
      <.header class="text-center">Reset Password</.header>

      <.simple_form
        for={@form}
        id="reset_password_form"
        phx-submit="reset_password"
        phx-change="validate"
      >
        <.error :if={@form.errors != []}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:password]} type="password" label="New password" required />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Confirm new password"
          required
        />
        <:actions>
          <.button
            phx-disable-with="Resetting..."
            class="shadow-xl border-2 border-gold-100 w-full bg-contrast text-zinc-950"
          >
            Reset Password
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_host_and_token(socket, params)

    form_source =
      case socket.assigns do
        %{host: host} ->
          Hosts.change_host_password(host)

        _ ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  def handle_event("reset_password", %{"host" => host_params}, socket) do
    host_params = Map.put(host_params, "token", socket.assigns.token)

    case Hosts.reset_password(socket.assigns.token, host_params["password"]) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> push_event("external_redirect", %{
           url: "https://client-dashboard-v2-seven.vercel.app/registration"
         })}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"host" => host_params}, socket) do
    changeset = Hosts.change_host_password(socket.assigns.host, host_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_host_and_token(socket, %{"token" => token}) do
    if host = Hosts.get_host_by_reset_password_token(token) do
      assign(socket, host: host, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: "/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "host"))
  end
end
