#!/bin/bash

echo "Stopping and removing all running containers..."

# Stop all running containers
docker stop $(docker ps -q)

# Remove all containers
docker rm $(docker ps -a -q)

echo "All containers have been stopped and removed."
