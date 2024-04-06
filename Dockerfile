# Stage 1: Build the Elixir/Phoenix Application
ARG RELEASE_VERSION=0.1.1`
ARG ELIXIR_VERSION=1.14.5
ARG OTP_VERSION=25.3.2.5
ARG DEBIAN_VERSION=bullseye-20230612-slim
ARG BUILDER_IMAGE="692454124440.dkr.ecr.us-east-1.amazonaws.com/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="692454124440.dkr.ecr.us-east-1.amazonaws.com/elixir:1.14.5-erlang-25.3.2.5-ubuntu-focal-20230126"

FROM ${BUILDER_IMAGE} as builder

# Install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Prepare build dir
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV="prod"

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy compile-time config files before we compile dependencies
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv
COPY lib lib
COPY assets assets
COPY global-bundle.pem /app/bin/global-bundle.pem

# Compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# Stage 2: Create the Final Docker Image
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && apt-get install -y libstdc++6 openssl imagemagick libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# Set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/quest_api_v21 ./
COPY --from=builder /app/bin/global-bundle.pem /app/bin/global-bundle.pem

USER nobody

CMD ["/app/bin/server"]