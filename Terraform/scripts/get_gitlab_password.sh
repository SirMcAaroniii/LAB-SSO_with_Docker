#!/usr/bin/env bash
set -euo pipefail
CONTAINER="$1"

# Jusqu’à 60 tentatives (≈ 2 min)
for _ in {1..60}; do
  if docker exec "$CONTAINER" test -f /etc/gitlab/initial_root_password; then
    pwd=$(docker exec "$CONTAINER" awk '/Password:/ {print $2}' /etc/gitlab/initial_root_password)
    printf '{"result":"%s"}' "$pwd"
    exit 0
  fi
  sleep 2
done

echo "Mot de passe introuvable après 120 s" >&2
exit 1
