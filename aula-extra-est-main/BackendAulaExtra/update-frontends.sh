#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

docker compose -f "$COMPOSE_FILE" build frontend backoffice
docker compose -f "$COMPOSE_FILE" up -d frontend backoffice

echo "Frontend disponível em http://localhost:3000"
echo "Backoffice disponível em http://localhost:3001"