# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config
require Logger

config :quest_api_v21,
  ecto_repos: [QuestApiV21.Repo],
  generators: [binary_id: true]

# guardian setup
config :quest_api_v21, QuestApiV21.Guardian,
  issuer: "quest_api_v21",
  secret_key: "Lx0gpm2fd8tsJkAkSkTMeTYc26IPuooCtbRhCM6+/Z+JThmul0pidj+lxvx7/uJI",
  partner_jwt_secret: System.get_env("PARTNER_JWT_SECRET")

config :quest_api_v21, QuestApiV21.HostGuardian,
  issuer: "quest_api_v21",
  secret_key: "Lx0gpm2fd8tsJkAkSkTMeTYc26IPuooCtbRhCM6+/Z+JThmul0pidj+lxvx7/uJI"

# Configures the endpoint
config :quest_api_v21, QuestApiV21Web.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: QuestApiV21Web.ErrorHTML, json: QuestApiV21Web.ErrorJSON],
    layout: false
  ],
  pubsub_server: QuestApiV21.PubSub,
  live_view: [signing_salt: "mWI7Ou9T"]

# Google ID
config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]}
  ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

config :quest_api_v21, QuestApiV21.Mailer,
  adapter: Swoosh.Adapters.AmazonSES,
  region: "us-east-1",
  access_key: System.get_env("AWS_ACCESS_KEY_ID"),
  secret: System.get_env("AWS_SECRET_ACCESS_KEY")

config :swoosh, :mailers, %{
  default: {Swoosh.Adapters.AmazonSES, []}
}

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args: [
      "js/app.js",
      "--bundle",
      "--minify",
      "--target=es2017",
      "--outdir=../priv/static/assets",
      "--external:/fonts/*",
      "--external:/images/*"
    ],
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

if Mix.env() != :prod do
  config :git_hooks,
    verbose: true,
    hooks: [
      pre_commit: [
        tasks: [
          {:cmd, "mix format --check-formatted"}
        ]
      ]
    ]
end
