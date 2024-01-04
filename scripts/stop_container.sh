#!/bin/bash
# Stop the current container (if running)
docker stop quest-api-v2 || true

# Remove the stopped container
docker rm quest-api-v2 || true
