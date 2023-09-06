#!/bin/bash

# Check if the container is running
if [ "$(docker ps -q -f name=quest-api-v2)" ]; then
    # Stop the container
    docker stop quest-api-v2
    # Optionally, remove the container
    docker rm quest-api-v2
fi
