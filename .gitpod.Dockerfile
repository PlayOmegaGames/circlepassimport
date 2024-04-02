FROM hexpm/elixir:1.14.5-erlang-25.3.2.5-ubuntu-focal-20230126

# Install locales package and generate en_US.UTF-8
USER root
RUN apt-get update && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8

# Set up environment variables
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ENV MIX_ENV=dev
ENV DEBIAN_FRONTEND=noninteractive

# Install Git, Inotify-tools, Fish, ImageMagick, and other dependencies
RUN apt-get update && \
    apt-get install -y git inotify-tools tzdata fish curl zip imagemagick build-essential && \
    ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get clean
