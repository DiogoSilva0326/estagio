#!/usr/bin/env bash
set -euo pipefail

# Uso: export GITHUB_TOKEN GHCR_NAMESPACE GITHUB_USERNAME
# ou coloca GHCR_NAMESPACE/GITHUB_USERNAME no .env (não commitar o .env!)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${ROOT_DIR}/.env" ]; then
  # shellcheck disable=SC1090
  source "${ROOT_DIR}/.env"
fi

cd "${ROOT_DIR}"

GHCR_NAMESPACE="${GHCR_NAMESPACE:-synget1-0/synget-site}"

: "${GITHUB_USERNAME:?Set GITHUB_USERNAME (or source it from .env)}"
: "${GITHUB_TOKEN:?Set GITHUB_TOKEN (or source it from .env)}"

TAG="${1:-1.0.0}"

# Build pg-backup image locally if it's not present (server cannot build images)
PG_BACKUP_LOCAL_IMAGE="pg-backup:${TAG}"
if ! docker image inspect "${PG_BACKUP_LOCAL_IMAGE}" > /dev/null 2>&1; then
  echo "🔨 Local image ${PG_BACKUP_LOCAL_IMAGE} not found — building from ./pg-backup for linux/amd64..."
  docker build --platform=linux/amd64 -t "${PG_BACKUP_LOCAL_IMAGE}" ./pg-backup
  echo "✅ Built ${PG_BACKUP_LOCAL_IMAGE} (linux/amd64)"
fi

echo "🔐 Logging in to ghcr.io as ${GITHUB_USERNAME}..."
echo "${GITHUB_TOKEN}" | docker login ghcr.io -u "${GITHUB_USERNAME}" --password-stdin
echo "✅ Logged"

# Map local -> remotes
declare -a IMAGES=(
  "synget-api:${TAG}=ghcr.io/${GHCR_NAMESPACE}/synget-api:${TAG}"
  "synget-site:${TAG}=ghcr.io/${GHCR_NAMESPACE}/synget-site:${TAG}"
  "synget-admin:${TAG}=ghcr.io/${GHCR_NAMESPACE}/synget-admin:${TAG}"
  "synget-gemini-api:${TAG}=ghcr.io/${GHCR_NAMESPACE}/synget-gemini-api:${TAG}"
  "synget-db-deploy:${TAG}=ghcr.io/${GHCR_NAMESPACE}/synget-db-deploy:${TAG}"
  "pg-backup:${TAG}=ghcr.io/${GHCR_NAMESPACE}/pg-backup:${TAG}"
)

for mapping in "${IMAGES[@]}"; do
  LOCAL="${mapping%%=*}"
  REMOTE="${mapping##*=}"

  # Only tag/push if local image exists
  if docker image inspect "${LOCAL}" > /dev/null 2>&1; then
    echo "🏷 Tagging ${LOCAL} -> ${REMOTE}"
    docker tag "${LOCAL}" "${REMOTE}"
    echo "📤 Pushing ${REMOTE}"
    docker push "${REMOTE}"
  else
    echo "⚠️  Local image ${LOCAL} not found — skipping."
  fi
done

echo "✅ All done."