#!/bin/bash
# This script runs database migrations

# Define the container name
CONTAINER_NAME=692454124440.dkr.ecr.us-east-1.amazonaws.com/quest-api

# Run the Ecto migrations within the container
sudo docker exec $CONTAINER_NAME mix ecto.migrate
