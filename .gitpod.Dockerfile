FROM hexpm/elixir:1.14.5-erlang-25.3.2.5-ubuntu-focal-20230126

# Set up environment variables
ENV MIX_ENV=dev

# Install Node.js and other dependencies
RUN apt-get update && \
    apt-get install -y nodejs npm inotify-tools && \
    apt-get clean
