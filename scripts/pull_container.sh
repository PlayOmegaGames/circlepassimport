#!/bin/bash
ECR_REPOSITORY=692454124440.dkr.ecr.us-east-1.amazonaws.com/quest-api
IMAGE_TAG=latest

# Authenticate Docker to the ECR Repository
sudo aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REPOSITORY

# Pull the latest image
docker pull $ECR_REPOSITORY:$IMAGE_TAG
