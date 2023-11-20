#!/bin/bash

# Define a delay in seconds
DELAY=30

# Sleep for the specified delay
echo "Waiting for $DELAY seconds before checking service..."
sleep $DELAY

# Define the container name and health check URLs
CONTAINER_NAME=quest-api-container
INTERNAL_HEALTH_CHECK_URL=http://localhost:4000/
PUBLIC_HEALTH_CHECK_URL=https://staging.api.quest.circlepass.io/

# Check if the Docker container is running
if ! sudo docker ps | grep -q $CONTAINER_NAME; then
    echo "Container $CONTAINER_NAME is not running."
    exit 1
fi

# Perform an internal health check
internal_response=$(curl --write-out '%{http_code}' --silent --output /dev/null $INTERNAL_HEALTH_CHECK_URL)

if [ "$internal_response" -ne 200 ]; then
    echo "Internal health check failed with response code: $internal_response"
    exit 1
fi

# Perform a public health check
public_response=$(curl --write-out '%{http_code}' --silent --output /dev/null $PUBLIC_HEALTH_CHECK_URL)

if [ "$public_response" -ne 200 ]; then
    echo "Public health check failed with response code: $public_response"
    exit 1
fi

echo "Service is up, running, and publicly accessible."
exit 0
