FROM hexpm/elixir:1.14.5-erlang-25.3.2.5-ubuntu-focal-20230126

# Set up environment variables
ENV MIX_ENV=dev
ENV DEBIAN_FRONTEND=noninteractive

# Install Git, Inotify-tools, Fish, ImageMagick, and other dependencies
RUN apt-get update && \
    apt-get install -y git inotify-tools tzdata fish curl zip imagemagick && \
    ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get clean

# Download and install Node.js from pre-built binaries
RUN curl -fsSL https://nodejs.org/dist/v18.17.1/node-v18.17.1-linux-x64.tar.gz | tar -xz -C /usr/local --strip-components=1 && \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs

# Add Node.js to the PATH (This might be redundant as it's already in /usr/local/bin which is typically in the PATH)
ENV PATH="/usr/local/bin:${PATH}"

# Verify Node.js and npm installations
RUN node --version && npm --version