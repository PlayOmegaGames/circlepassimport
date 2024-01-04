#!/bin/bash

cd /home/ubuntu/


# Run the new container
docker run -d --env-file .env --name quest-api-v2 -p 4000:4000 692454124440.dkr.ecr.us-east-1.amazonaws.com/quest-api
