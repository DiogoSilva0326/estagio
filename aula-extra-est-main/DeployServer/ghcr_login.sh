#!/usr/bin/env bash
set -euo pipefail

# Optional: load env file if present
ENV_FILE="${ENV_FILE:-../.env.prod}"
if [[ -f "$ENV_FILE" ]]; then
	# shellcheck disable=SC2046
	export $(grep -E '^(OWNER|GITHUB_TOKEN)=' "$ENV_FILE" | xargs)
fi

: "${OWNER:?Define OWNER (utilizador/organização GitHub)}"
: "${GITHUB_TOKEN:?Define GITHUB_TOKEN com o teu token do GitHub (PAT)}"

echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$OWNER" --password-stdin
echo "✅ Login feito em ghcr.io como $OWNER"
