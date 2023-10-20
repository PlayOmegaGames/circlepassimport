# Use an official Elixir runtime as a parent image
FROM elixir:1.14

# Set environment variables for Phoenix
ENV MIX_ENV=dev \
    PORT=4000 \
    DATABASE_URL=ecto://QuestPostUser:sIicd8dCd3ZrFjfcijd1EokuV97BUR@questdb.cj9dqvip3fe8.us-east-1.rds.amazonaws.com/quest_api_v21_dev \
    SECRET_KEY_BASE=xJg+HnmI809UdF0Il2Imb8dQ8m3w8UI5PMkIT8ZNSc01weSDNhABBLFJm02PguKp

# Create and set the working directory
WORKDIR /app

# Update the system and install essential build tools
RUN apt-get update && apt-get install -y build-essential && apt-get clean

# Copy the current directory contents into the container at /app
COPY . .

# Remove any existing compiled files and the _build directory
RUN rm -rf _build

# Fetch project dependencies again
RUN mix deps.get --force

# Compile the project again
RUN mix compile

# Expose port 4000
EXPOSE 4000

# Compile static assets
RUN mix phx.digest

# Install Hex, Rebar, and run the Phoenix server
CMD mix local.hex --force && mix local.rebar --force && mix phx.server
