#!/bin/bash

# Check if a container named 'quest-api-v2' is already running, and if so, stop and remove it.
existing_container=$(docker ps -a --filter "name=quest-api-v2" -q)
if [ ! -z "$existing_container" ]; then
  echo "Stopping and removing existing container named 'quest-api-v2'..."
  docker stop quest-api-v2
  docker rm quest-api-v2
fi

# Now run your new container
docker run -d --name quest-api-v2 jaybecker/quest-api-v2:latest

echo "New container 'quest-api-v2' has been started."
