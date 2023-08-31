FROM hexpm/elixir:1.14.0-erlang-25.0-debian-buster-20210329

# Set up environment variables
ENV MIX_ENV=dev

# Install Node.js and other dependencies
RUN apt-get update && \
    apt-get install -y nodejs npm inotify-tools && \
    apt-get clean
