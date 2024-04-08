#!/bin/bash

# Assuming this script is executed with root privileges or with a user that has appropriate permissions

cd /home/ubuntu/

# Source the environment variables from the .env file
if [ -f ".env" ]; then
    source .env
else
    echo "The .env file does not exist. Exiting..."
    exit 1
fi

# Construct the image URI using REPOSITORY_URI and ENVIRONMENT variables
IMAGE_URI="${REPOSITORY_URI}/quest-api:${ENVIRONMENT}"

# Log in to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${REPOSITORY_URI%/*}

if [ $? -ne 0 ]; then
    echo "Docker login failed. Exiting..."
    exit 1
fi

# Pull the Docker image using the constructed IMAGE_URI
docker pull $IMAGE_URI

if [ $? -ne 0 ]; then
    echo "Failed to pull the Docker image. Exiting..."
    exit 1
fi

# Running migration
docker run --env-file .env --rm $IMAGE_URI /app/bin/quest_api_v21 eval "QuestApiV21.Release.migrate"

if [ $? -ne 0 ]; then
    echo "Migration command failed. Exiting..."
    exit 1
fi
