defmodule QuestApiV21Web.Account.AccountRegistrationLive do
  use QuestApiV21Web, :live_view

  alias QuestApiV21.Accounts
  alias QuestApiV21.Accounts.Account

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm bg-transparent">
      <div class="sm:mx-auto sm:w-full sm:max-w-sm pt-8 pb-4">
        <img
          class="mx-auto h-20 w-auto shadow-lg shadow-brand ring-offset-4 ring-2 ring-slate-100 rounded-full"
          src="/images/purplecirclequestlogo.svg"
          alt="Quest Logo"
        />
      </div>

      <.header class="text-center">
        Sign Up
        <:subtitle>
          Already have an account?
          <.link navigate={~p"/accounts/log_in"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/accounts/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:name]} type="text" label="Name" required />
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
      <p class="text-center text-black my-2">or</p>
      <div class="flex justify-center">
        <a href="/auth/google">
          <.google />
        </a>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_account_registration(%Account{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  # Handles the "save" event triggered on form submission
  def handle_event("save", %{"account" => account_params}, socket) do
    case Accounts.register_account(account_params) do
      {:ok, account} ->
        # This block is executed when the user is successfully registered.
        # Deliver account confirmation instructions via email or other means.
        {:ok, _} =
          Accounts.deliver_account_confirmation_instructions(
            account,
            fn token -> "https://questapp.io/accounts/confirm/#{token}" end
          )

        # Prepare a new changeset for the registered account, typically for updating UI or redirecting.
        changeset = Accounts.change_account_registration(account)

        # Update the socket to trigger the form submission process and assign the updated form changeset.
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        # This branch is not related to successful registration but handles errors in registration.
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"account" => account_params}, socket) do
    changeset = Accounts.change_account_registration(%Account{}, account_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "account")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
