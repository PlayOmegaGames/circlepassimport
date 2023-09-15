#!/bin/bash

# Run the Docker container with bind mount and port mapping
docker run -d -p 4000:4000 --name quest-api-v2 --mount type=bind,source=/var/www/html/quest,target=/app jaybecker/quest-api-v2
