#!/usr/bin/env bash
set -euo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${DEPLOY_DIR}/.env" ]; then
  # shellcheck disable=SC1091
  source "${DEPLOY_DIR}/.env"
fi

: "${GITHUB_USERNAME:?Set GITHUB_USERNAME no ambiente ou no ficheiro .env}"
: "${GITHUB_TOKEN:?Set GITHUB_TOKEN no ambiente ou no ficheiro .env}"

GHCR_NAMESPACE="${GHCR_NAMESPACE:-synget1-0/aula-extra}"
TAG="${1:-${TAG:-1.0.0}}"

echo "🔐 Logging in to ghcr.io as ${GITHUB_USERNAME}..."
echo "${GITHUB_TOKEN}" | docker login ghcr.io -u "${GITHUB_USERNAME}" --password-stdin

declare -a IMAGES=(
  "aulaextra-api:${TAG}=ghcr.io/${GHCR_NAMESPACE}/aulaextra-api:${TAG}"
  "aulaextra-frontend:${TAG}=ghcr.io/${GHCR_NAMESPACE}/aulaextra-frontend:${TAG}"
  "aulaextra-backoffice:${TAG}=ghcr.io/${GHCR_NAMESPACE}/aulaextra-backoffice:${TAG}"
  "aulaextra-agora-integrator:${TAG}=ghcr.io/${GHCR_NAMESPACE}/aulaextra-agora-integrator:${TAG}"
  "aulaextra-r2-integrator:${TAG}=ghcr.io/${GHCR_NAMESPACE}/aulaextra-r2-integrator:${TAG}"
  "aulaextra-db-deploy:${TAG}=ghcr.io/${GHCR_NAMESPACE}/aulaextra-db-deploy:${TAG}"
)

declare -a MISSING_IMAGES=()

for mapping in "${IMAGES[@]}"; do
  LOCAL="${mapping%%=*}"
  if ! docker image inspect "${LOCAL}" > /dev/null 2>&1; then
    MISSING_IMAGES+=("${LOCAL}")
  fi
done

if [ ${#MISSING_IMAGES[@]} -gt 0 ]; then
  echo "❌ Faltam imagens locais para a tag ${TAG}:" >&2
  for image in "${MISSING_IMAGES[@]}"; do
    echo "   - ${image}" >&2
  done
  echo "   Executa primeiro: ./build.sh ${TAG}" >&2
  exit 1
fi

for mapping in "${IMAGES[@]}"; do
  LOCAL="${mapping%%=*}"
  REMOTE="${mapping##*=}"

  echo "🏷 Tagging ${LOCAL} -> ${REMOTE}"
  docker tag "${LOCAL}" "${REMOTE}"
  echo "📤 Pushing ${REMOTE}"
  docker push "${REMOTE}"
done

echo "✅ Push finished."
