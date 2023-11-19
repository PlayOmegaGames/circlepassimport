#!/bin/bash

# Define the ECR repository and image name
ECR_REPOSITORY=692454124440.dkr.ecr.us-east-1.amazonaws.com/quest-api
IMAGE_TAG=latest # or specific version tag if required
CONTAINER_NAME=692454124440.dkr.ecr.us-east-1.amazonaws.com/quest-api

# Run a new Docker container from the image pulled from ECR
echo "Starting new container..."
sudo docker run -d -p 4000:4000 --name $CONTAINER_NAME $ECR_REPOSITORY:$IMAGE_TAG
