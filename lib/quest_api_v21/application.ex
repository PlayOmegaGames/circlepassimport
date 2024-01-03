defmodule QuestApiV21.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger


  @impl true
  def start(_type, _args) do
    # For debugging secrets
    google_client_id = System.get_env("GOOGLE_CLIENT_ID")
    Logger.info("Google Client ID: #{google_client_id}")

    configure_ueberauth()


    children = [
      # Start the Telemetry supervisor
      QuestApiV21Web.Telemetry,
      # Start the Ecto repository
      QuestApiV21.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: QuestApiV21.PubSub},
      # Start Finch
      {Finch, name: QuestApiV21.Finch},
      # Start the Endpoint (http/https)
      QuestApiV21Web.Endpoint
      # Start a worker by calling: QuestApiV21.Worker.start_link(arg)
      # {QuestApiV21.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QuestApiV21.Supervisor]
    Supervisor.start_link(children, opts)

  end

  defp configure_ueberauth do
    config = [
      client_id: System.get_env("GOOGLE_CLIENT_ID"),
      client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
      redirect_uri: System.get_env("GOOGLE_REDIRECT_URI")
    ]

    Application.put_env(:ueberauth, Ueberauth.Strategy.Google.OAuth, config)
  end
  
  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QuestApiV21Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
