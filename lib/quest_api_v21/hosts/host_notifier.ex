defmodule QuestApiV21.Hosts.HostNotifier do
  import Swoosh.Email

  alias QuestApiV21.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Quest", "support@questapp.io"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to reset a host password.
  find url variable in hosts context file
  """
  def deliver_reset_password_instructions(host, url) do
    deliver(host.email, "Reset password instructions", """

    ==============================

    Hi #{host.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
