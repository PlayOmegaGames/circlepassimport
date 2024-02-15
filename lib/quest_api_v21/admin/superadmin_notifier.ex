defmodule QuestApiV21.Admin.SuperadminNotifier do
  import Swoosh.Email

  alias QuestApiV21.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"QuestApiV21", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(superadmin, url) do
    deliver(superadmin.email, "Confirmation instructions", """

    ==============================

    Hi #{superadmin.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a superadmin password.
  """
  def deliver_reset_password_instructions(superadmin, url) do
    deliver(superadmin.email, "Reset password instructions", """

    ==============================

    Hi #{superadmin.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a superadmin email.
  """
  def deliver_update_email_instructions(superadmin, url) do
    deliver(superadmin.email, "Update email instructions", """

    ==============================

    Hi #{superadmin.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
