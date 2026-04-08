#!/bin/sh
set -eu

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"
DB_NAME="${DB_NAME:-postgres}"
DB_SEED="${DB_SEED:-1}"

export PGPASSWORD="${DB_PASSWORD:-}"

wait_for_db() {
  echo "Waiting for PostgreSQL at ${DB_HOST}:${DB_PORT}/${DB_NAME}..."
  until pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" >/dev/null 2>&1; do
    sleep 2
  done
}

run_sql() {
  sql_file="$1"
  echo "Applying ${sql_file}"
  psql \
    -h "${DB_HOST}" \
    -p "${DB_PORT}" \
    -U "${DB_USER}" \
    -d "${DB_NAME}" \
    -v ON_ERROR_STOP=1 \
    -f "${sql_file}"
}

wait_for_db
run_sql /app/migration/apply_ordered.sql

if [ "${DB_SEED}" = "1" ]; then
  run_sql /app/sql/postgres/seed_dev.sql
else
  echo "Skipping dev seed because DB_SEED=${DB_SEED}"
fi

echo "Database deploy completed successfully."
