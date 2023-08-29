#!/bin/bash

# Change directory to your app's deployment directory
cd /var/www/html/quest

# Install Hex package manager
mix local.hex --force

# Install rebar3
mix local.rebar --force

# Install project dependencies
mix deps.get --only prod

# Compile the Phoenix application
mix compile


# Perform any necessary database migrations
