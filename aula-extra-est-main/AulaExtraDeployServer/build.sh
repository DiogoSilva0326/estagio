#!/usr/bin/env bash
set -euo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "${DEPLOY_DIR}/.." && pwd)"

if [ -f "${DEPLOY_DIR}/.env" ]; then
  # shellcheck disable=SC1091
  source "${DEPLOY_DIR}/.env"
fi

TAG="${1:-${TAG:-1.0.0}}"
DOCKER_PLATFORM="${DOCKER_PLATFORM:-linux/amd64}"

normalize_base_href() {
  local value="${1:-/}"

  value="${value%%\?*}"
  value="${value%%\#*}"

  if [[ "${value}" =~ ^https?://[^/]+(/.*)?$ ]]; then
    value="${BASH_REMATCH[1]:-/}"
  fi

  if [[ -z "${value}" ]]; then
    value="/"
  fi

  if [[ "${value}" != /* ]]; then
    value="/${value}"
  fi

  if [[ "${value}" != */ ]]; then
    value="${value}/"
  fi

  echo "${value}"
}

if [[ ! "${TAG}" =~ ^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}$ ]]; then
  echo "❌ TAG inválida: '${TAG}'" >&2
  echo "   Usa algo como 1.0.0, test-20260330 ou v1.0.0" >&2
  exit 1
fi

echo "🔨 Building Aula Extra images with tag: ${TAG}"

FRONTEND_BASE_HREF_NORMALIZED="$(normalize_base_href "${FRONTEND_BASE_HREF:-/}")"
BACKOFFICE_BASE_HREF_NORMALIZED="$(normalize_base_href "${BACKOFFICE_BASE_HREF:-/}")"

echo "🌐 Frontend base href: ${FRONTEND_BASE_HREF_NORMALIZED}"
echo "🧭 Backoffice base href: ${BACKOFFICE_BASE_HREF_NORMALIZED}"

docker build --platform="${DOCKER_PLATFORM}" \
  -t aulaextra-api:${TAG} \
  -f "${WORKSPACE_DIR}/BackendAulaExtra/Dockerfile" \
  "${WORKSPACE_DIR}/BackendAulaExtra"

docker build --platform="${DOCKER_PLATFORM}" \
  -t aulaextra-frontend:${TAG} \
  --build-arg API_BASE_URL="${API_BASE_URL:-}" \
  --build-arg CHAT_HUB_BASE_URL="${CHAT_HUB_BASE_URL:-}" \
  --build-arg APP_BASE_HREF="${FRONTEND_BASE_HREF_NORMALIZED}" \
  -f "${DEPLOY_DIR}/Dockerfile.frontend" \
  "${WORKSPACE_DIR}"

docker build --platform="${DOCKER_PLATFORM}" \
  -t aulaextra-backoffice:${TAG} \
  --build-arg API_BASE_URL="${BACKOFFICE_API_BASE_URL:-${API_BASE_URL:-}}" \
  --build-arg APP_BASE_HREF="${BACKOFFICE_BASE_HREF_NORMALIZED}" \
  -f "${DEPLOY_DIR}/Dockerfile.backoffice" \
  "${WORKSPACE_DIR}"

docker build --platform="${DOCKER_PLATFORM}" \
  -t aulaextra-db-deploy:${TAG} \
  -f "${DEPLOY_DIR}/Dockerfile.db-deploy" \
  "${WORKSPACE_DIR}"

AGORA_CONTEXT_DIR="${WORKSPACE_DIR}/BackendAulaExtra/AgoraIntegrator/Src"
AGORA_DOCKERFILE="${AGORA_CONTEXT_DIR}/Synget.AgoraIntegrator.API/Dockerfile"
if [ -f "${AGORA_DOCKERFILE}" ]; then
  docker build --platform="${DOCKER_PLATFORM}" \
    -t aulaextra-agora-integrator:${TAG} \
    -f "${AGORA_DOCKERFILE}" \
    "${AGORA_CONTEXT_DIR}"
fi

R2_CONTEXT_DIR="${WORKSPACE_DIR}/BackendAulaExtra/R2_Integrator/src"
R2_DOCKERFILE="${R2_CONTEXT_DIR}/Synget_R2.Integrator.API/Dockerfile"
if [ -f "${R2_DOCKERFILE}" ]; then
  docker build --platform="${DOCKER_PLATFORM}" \
    -t aulaextra-r2-integrator:${TAG} \
    -f "${R2_DOCKERFILE}" \
    "${R2_CONTEXT_DIR}"
fi

echo "✅ Build finished with tag: ${TAG}"
