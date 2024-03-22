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


