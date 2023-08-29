#!/bin/bash

# Change directory to your app's deployment directory
cd /var/www/html/quest

# Set environment variables
export MIX_ENV=prod
export PORT=4000
export SECRET_KEY_BASE=$(mix phx.gen.secret)
mix ecto.migrate
# Build the release
mix release

# Change to the release directory
cd _build/prod/rel/quest_api

# Start the Phoenix server in the background and select yes when asked for overwriting
DATABASE_URL="$DATABASE_URL" ./bin/quest_api start > server.log 2>&1 &
