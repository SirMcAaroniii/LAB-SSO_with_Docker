#!/usr/bin/env sh
set -e

container="$1"
pubkey="$2"

docker cp "$pubkey" "$container":/root/ansible_key.pub
docker exec "$container" sh -c '
  mkdir -p /root/.ssh &&
  cat /root/ansible_key.pub >> /root/.ssh/authorized_keys &&
  chmod 600 /root/.ssh/authorized_keys &&
  chmod 700 /root/.ssh &&
  rm /root/ansible_key.pub
'
