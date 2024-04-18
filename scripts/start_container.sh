#!/bin/bash

cd /home/ubuntu/

# Source the environment variables from the .env file
if [ -f ".env" ]; then
    source .env
else
    echo "The .env file does not exist. Exiting..."
    exit 1
fi

IMAGE_URI="${REPOSITORY_URI}:${ENVIRONMENT}"

# Run the new container
docker run -d --env-file .env --name quest-api-v2 -p 4000:4000 $IMAGE_URI


