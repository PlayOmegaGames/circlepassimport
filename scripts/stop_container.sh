#!/bin/bash

cd /home/ubuntu/



# Source the environment variables from the .env file
if [ -f ".env" ]; then
    source .env
else
    echo "The .env file does not exist. Exiting..."
    exit 1
fi

echo $IMAGE_NAME

# Stop the current container (if running)
docker stop quest-api-v2

# Remove the stopped container
docker rm quest-api-v2

# Prune unused Docker images
docker image prune -a -f