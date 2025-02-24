import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :quest_api_v21, QuestApiV21.Repo,
  username: "QuestPostUser",
  password: "sIicd8dCd3ZrFjfcijd1EokuV97BUR",
  hostname: "questdb.cj9dqvip3fe8.us-east-1.rds.amazonaws.com",
  database: "quest_api_v21_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :quest_api_v21, QuestApiV21Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/mJWKdJkNpBc/ljmJGS5WXOUOgY1rgANITqdHU1a5Rskqkr0Y4NT0O5RU5YnoHdb",
  server: false

# In test we don't send emails.
config :quest_api_v21, QuestApiV21.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
