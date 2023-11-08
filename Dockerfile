# Use an official Elixir runtime as a parent image
FROM elixir:1.14

# Set environment variables for Phoenix
ENV MIX_ENV=dev \
    PORT=4000 \
    DATABASE_URL=ecto://QuestPostUser:sIicd8dCd3ZrFjfcijd1EokuV97BUR@questdb.cj9dqvip3fe8.us-east-1.rds.amazonaws.com/quest_api_v21_dev \
    SECRET_KEY_BASE=xJg+HnmI809UdF0Il2Imb8dQ8m3w8UI5PMkIT8ZNSc01weSDNhABBLFJm02PguKp

# Create and set the working directory
WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install system dependencies and clean up
RUN apt-get update && \
    apt-get install -y build-essential inotify-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy only the necessary project files
COPY mix.exs mix.lock ./
COPY config config/
COPY lib lib/
COPY priv priv/
COPY test test/

# Fetch and compile the project dependencies
RUN mix do deps.get, deps.compile

# Compile the project
RUN mix compile

# Expose port 4000
EXPOSE 4000

# Compile static assets
RUN mix phx.digest

# Run the Phoenix server
CMD ["mix", "phx.server"]
