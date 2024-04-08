#!/bin/bash

cd /home/ubuntu/

# Source the environment variables from the .env file
source .env

# Construct the image URI using REPOSITORY_URI and ENVIRONMENT variables
IMAGE_URI="$REPOSITORY_URI/quest-api:$ENVIRONMENT"

# Log in to ECR
$(aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${REPOSITORY_URI})

# Pull the Docker image using the constructed IMAGE_URI
docker pull $IMAGE_URI

# Running migration
docker run --env-file .env --rm $IMAGE_URI /app/bin/quest_api_v21 eval "QuestApiV21.Release.migrate"
