#!/usr/bin/env bash
set -euo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ENV_FILE:-${DEPLOY_DIR}/.env}"

if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  export $(grep -E '^(GITHUB_USERNAME|OWNER|GITHUB_TOKEN)=' "${ENV_FILE}" | xargs)
fi

: "${GITHUB_USERNAME:?Define GITHUB_USERNAME com o utilizador real do GitHub que emitiu o PAT}"
: "${GITHUB_TOKEN:?Define GITHUB_TOKEN com o teu PAT do GitHub}"

echo "${GITHUB_TOKEN}" | docker login ghcr.io -u "${GITHUB_USERNAME}" --password-stdin
echo "✅ Login feito em ghcr.io como ${GITHUB_USERNAME}"
