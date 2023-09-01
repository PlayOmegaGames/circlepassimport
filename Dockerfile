# Use an official Elixir runtime as a parent image
FROM elixir:1.14

# Set environment variables for Phoenix
ENV MIX_ENV=dev
ENV PORT=4000
ENV DATABASE_URL=ecto://QuestPostUser:sIicd8dCd3ZrFjfcijd1EokuV97BUR@questdb.cj9dqvip3fe8.us-east-1.rds.amazonaws.com/quest_api_v21_dev
ENV SECRET_KEY_BASE=xJg+HnmI809UdF0Il2Imb8dQ8m3w8UI5PMkIT8ZNSc01weSDNhABBLFJm02PguKp

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create and set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . .

# Install project dependencies
RUN mix deps.get

# Compile the project
RUN mix compile

# Expose port 4000
EXPOSE 4000


# Compile static assets
RUN mix phx.digest

# Run the Phoenix server
CMD ["mix", "phx.server"]
