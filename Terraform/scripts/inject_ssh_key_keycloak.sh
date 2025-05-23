#!/bin/bash
CONTAINER_NAME=$1
PUB_KEY_PATH=$2

# Trouve le home du user courant (ex: /opt/keycloak)
HOME_DIR=$(docker exec "$CONTAINER_NAME" sh -c 'echo $HOME')

docker exec "$CONTAINER_NAME" sh -c "mkdir -p $HOME_DIR/.ssh && chmod 700 $HOME_DIR/.ssh"
docker cp "$PUB_KEY_PATH" "$CONTAINER_NAME:$HOME_DIR/.ssh/authorized_keys"
docker exec "$CONTAINER_NAME" sh -c "chmod 600 $HOME_DIR/.ssh/authorized_keys"