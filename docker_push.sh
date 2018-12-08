#!/bin/bash
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker build -t jonhkr/simplebank:latest .
docker push jonhkr/simplebank:latest