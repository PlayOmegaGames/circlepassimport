#!/bin/bash

cd /home/ubuntu/

# Assuming imagedefinitions.json is in the current directory and contains the imageUri

# Extract the imageUri using jq - make sure jq is installed
IMAGE_URI=$(jq -r '.[0].imageUri' imagedefinitions.json)

# Log in to ECR
$(aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${IMAGE_URI%:*})

# Pull the Docker image specified in imagedefinitions.json
docker pull $IMAGE_URI

# Running migration
docker run --env-file .env --rm $IMAGE_URI /app/bin/quest_api_v21 eval "QuestApiV21.Release.migrate"
