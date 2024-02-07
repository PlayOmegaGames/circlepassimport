#!/bin/bash

cd /home/ubuntu/

# Stop the current container (if running)
docker stop quest-api-v2 || true

# Remove the stopped container
docker rm quest-api-v2 || true

# Prune unused Docker images
docker image prune -a -f