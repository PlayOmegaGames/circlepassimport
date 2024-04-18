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
docker stop $IMAGE_NAME

# Remove the stopped container
docker rm $IMAGE_NAME

# Prune unused Docker images
docker image prune -a -f