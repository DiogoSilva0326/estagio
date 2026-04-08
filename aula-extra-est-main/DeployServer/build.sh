#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Carrega .env opcional (apenas local) - NÃO COMMITAR .env com segredos
if [ -f "${ROOT_DIR}/.env" ]; then
  # shellcheck disable=SC1090
  source "${ROOT_DIR}/.env"
fi

# Build tags (passar TAG como primeiro argumento, default 1.0.0)
# Nota: calculado após carregar .env para evitar que o .env sobrescreva o argumento.
TAG="${1:-${TAG:-1.0.0}}"

# Docker tag validation (avoid invalid references like "1:-1.0.0")
if [[ ! "${TAG}" =~ ^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}$ ]]; then
  echo "❌ TAG inválida: '${TAG}'" >&2
  echo "   Usa algo como 1.0.0 (apenas letras/números/._-)" >&2
  exit 
fi

echo "🔨 Building images with tag: ${TAG}"

# Back-end API (ConfidantPostgreSQL)
docker build --platform=linux/amd64 \
  -t synget-api:${TAG} \
  -f "${ROOT_DIR}/ConfidantPostgreSQL/Dockerfile" \
  "${ROOT_DIR}/ConfidantPostgreSQL"

# pg-backup
if [ -f "${ROOT_DIR}/pg-backup/Dockerfile" ]; then
  docker build --platform=linux/amd64 \
    -t pg-backup:${TAG} \
    -f "${ROOT_DIR}/pg-backup/Dockerfile" \
    "${ROOT_DIR}/pg-backup"
fi

# Frontend (synget-site)
if [ -f "${ROOT_DIR}/synget-site/Dockerfile" ]; then
  docker build --platform=linux/amd64 \
    -t synget-site:${TAG} \
    --build-arg API_BASE_URL="${API_BASE_URL:-}" \
    --build-arg STORE_ID="${STORE_ID:-}" \
    -f "${ROOT_DIR}/synget-site/Dockerfile" \
    "${ROOT_DIR}/synget-site"
fi

# Frontend (synget-admin)
if [ -f "${ROOT_DIR}/synget_admin/Dockerfile" ]; then
  docker build --platform=linux/amd64 \
    -t synget-admin:${TAG} \
    --build-arg API_BASE_URL="${API_BASE_URL:-}" \
    -f "${ROOT_DIR}/synget_admin/Dockerfile" \
    "${ROOT_DIR}/synget_admin"
fi

# Gemini API (SyngetGemini.Api)
# Build context must be the SyngetGemini solution root so project references resolve.
GEMINI_SOLUTION_DIR="${ROOT_DIR}/ConfidantPostgreSQL/src/GeminiChatBot/Gemini/SyngetGemini"
GEMINI_API_DOCKERFILE="${GEMINI_SOLUTION_DIR}/SyngetGemini.Api/Dockerfile"
if [ -f "${GEMINI_API_DOCKERFILE}" ]; then
  docker build --platform=linux/amd64 \
    -t synget-gemini-api:${TAG} \
    -f "${GEMINI_API_DOCKERFILE}" \
    "${GEMINI_SOLUTION_DIR}"
fi



echo "✅ Build finished with tag: ${TAG}"