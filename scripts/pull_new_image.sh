#!/bin/bash
# Log in to ECR
$(aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 692454124440.dkr.ecr.us-east-1.amazonaws.com)

# Pull the latest Docker image
docker pull 692454124440.dkr.ecr.us-east-1.amazonaws.com/quest-api:latest
