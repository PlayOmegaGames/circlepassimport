import Config

config :quest_api_v21, QuestApiV21.Repo,
  ssl: true,
  ssl_opts: [cacertfile: "/app/bin/global-bundle.pem", verify: :verify_none],
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  hostname: System.get_env("DB_HOSTNAME"),
  database: System.get_env("DB_NAME")

# Endpoint configuration for serving the application
config :quest_api_v21, QuestApiV21Web.Endpoint,
  url: [
    host: System.get_env("HOSTNAME") || "staging.api.quest.circlepass.io",
    port: 443,
    scheme: "https"
  ],
  check_origin: [
    "http://localhost:4000",
    "https://staging.questapp.io",
    "https://questapp.io/",
    "https://gitpod.io.",
    "https://client-dashboard-v2-zeta.vercel.app"
  ],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
config :quest_api_v21, QuestApiV21Web.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :quest_api_v21, QuestApiV21Web.WebhookController, verify_stripe_signature: true
# Ensure the Swoosh API client is configured for your choice of HTTP client, if necessary
# config :swoosh, :api_client, Swoosh.ApiClient.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :debug

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
