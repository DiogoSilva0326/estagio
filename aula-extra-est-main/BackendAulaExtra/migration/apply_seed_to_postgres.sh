#!/usr/bin/env bash
set -euo pipefail

# 1. Impede o Git Bash de converter caminhos do contentor Docker (ex: /tmp/...)
export MSYS_NO_PATHCONV=1

# 2. Força os caminhos a usar o formato Windows (C:/...) se estiver no Git Bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd -W 2>/dev/null || pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -W 2>/dev/null || pwd)"

ENV_FILE="$PROJECT_ROOT/.env"
if [[ -f "$ENV_FILE" ]]; then
  while IFS='=' read -r key value; do
    [[ -z "${key//[[:space:]]/}" ]] && continue
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    key="${key%%[[:space:]]*}"
    value="${value#\"}"; value="${value%\"}"
    value="${value#\'}"; value="${value%\'}"
    export "$key=$value"
  done < "$ENV_FILE"
fi

: "${CONTAINER:=confidantpostgresAulaExtra}"
: "${DB_USER:=${SQL_USER:-confidants_user}}"
: "${DB_NAME:=${SQL_DB:-ConfidantsDB}}"

SEED_FILE="$PROJECT_ROOT/sql/postgres/seed_dev.sql"

if [[ ! -f "$SEED_FILE" ]]; then
  echo "Seed file not found at '$SEED_FILE'." >&2
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Docker container '${CONTAINER}' is not running." >&2
  exit 1
fi

echo "Applying seed: $SEED_FILE"
docker cp "$SEED_FILE" "$CONTAINER":/tmp/seed_dev.sql
docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f /tmp/seed_dev.sql

echo "Done."