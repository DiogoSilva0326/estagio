#!/usr/bin/env bash
set -euo pipefail
export MSYS_NO_PATHCONV=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd -W 2>/dev/null || pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -W 2>/dev/null || pwd)"
ORDERED_FILE="$SCRIPT_DIR/apply_ordered.sql"

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

# Defaults (computed after loading .env)
: "${CONTAINER:=confidantpostgresAulaExtra}"
# Prefer repo's docker-compose env var names if DB_* are not provided
: "${DB_USER:=${SQL_USER:-confidants_user}}"
: "${DB_NAME:=${SQL_DB:-ConfidantsDB}}"

# Optional: reset schemas to avoid leftover tables from other projects/old volumes.
# Defaults to enabled so repeated local runs start from a clean DB.
: "${RESET_PUBLIC_SCHEMA:=1}"
: "${RESET_AULA_EXTRA_SCHEMA:=1}"

reset_schemas() {
  if [[ "$RESET_PUBLIC_SCHEMA" == "1" ]]; then
    echo "== Resetting schema: public (CASCADE) =="
    docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -c "DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public; GRANT ALL ON SCHEMA public TO postgres; GRANT ALL ON SCHEMA public TO public;"
  fi

  if [[ "$RESET_AULA_EXTRA_SCHEMA" == "1" ]]; then
    echo "== Resetting schema: aula_extra (CASCADE) =="
    docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -c "DROP SCHEMA IF EXISTS aula_extra CASCADE;"
  fi
}

apply_file() {
  local host_path="$1"
  local base
  base=$(basename "$host_path")
  local hash
  hash=$(printf '%s' "$host_path" | shasum -a 256 | awk '{print $1}')
  local tmp_name="${hash}_${base}"

  echo "Applying $host_path -> /tmp/$tmp_name in $CONTAINER"
  docker cp "$host_path" "$CONTAINER":/tmp/"$tmp_name"
  docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f /tmp/"$tmp_name"

  # Compatibility patches for this repo's SQL procs (keeps schema minimal but consistent)
  case "$base" in
    create_users_table.sql)
      docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -c "CREATE TABLE IF NOT EXISTS public.role (id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, description TEXT NOT NULL UNIQUE);"
      docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -c "INSERT INTO public.role (description) VALUES ('Standard'),('admin'),('professor'),('aluno') ON CONFLICT (description) DO NOTHING;"
      docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -c "ALTER TABLE public.users ADD COLUMN IF NOT EXISTS moloni_customer_id VARCHAR(255);"
      docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -c "DO \$\$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'toc_online_customer_id') THEN UPDATE public.users SET moloni_customer_id = toc_online_customer_id WHERE moloni_customer_id IS NULL AND toc_online_customer_id IS NOT NULL; END IF; END \$\$;"
      ;;
  esac
}

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Docker container '${CONTAINER}' is not running." >&2
  exit 1
fi

reset_schemas

echo "== Applying migration CREATE files =="
for f in "$SCRIPT_DIR"/create_*.sql; do
  [ -f "$f" ] || continue
  apply_file "$f"
done

if [[ -f "$ORDERED_FILE" ]]; then
  echo "== Applying module DDL/PROCs in ordered way from $ORDERED_FILE =="
  BASE_DIR="$(cd "$(dirname "$ORDERED_FILE")" && pwd -W 2>/dev/null || pwd)"
  while IFS= read -r line; do
    case "$line" in
      \\i*|\\ir*)
        sql_path=$(echo "$line" | sed -E "s/\\\\i[r]? '([^']+)'.*/\\1/")
        [ -n "$sql_path" ] || continue
        if [[ "$sql_path" == /* ]]; then
          host_path="$sql_path"
        else
          host_path="$BASE_DIR/$sql_path"
        fi
        [ -f "$host_path" ] || continue
        apply_file "$host_path"
        ;;
    esac
  done < "$ORDERED_FILE"
else
  echo "ERROR: apply_ordered.sql not found at '$ORDERED_FILE'." >&2
  echo "This project runs in strict mode to avoid creating tables that do not belong to Aula Extra." >&2
  echo "Fix: ensure '$SCRIPT_DIR/apply_ordered.sql' exists (it should be committed) or pass ORDERED_FILE explicitly." >&2
  exit 1
fi

echo "Done. If any errors occurred they were printed above."
