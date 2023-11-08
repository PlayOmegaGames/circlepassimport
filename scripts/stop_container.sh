#!/bin/bash

# Stop all running Docker containers
echo "Stopping all running containers..."
sudo docker stop $(sudo docker ps -aq)

# Remove all stopped containers
echo "Removing all containers..."
sudo docker rm $(sudo docker ps -aq)

# Optional: Cleanup unused Docker images and networks
echo "Cleaning up unused Docker images and networks..."
sudo docker system prune -af
