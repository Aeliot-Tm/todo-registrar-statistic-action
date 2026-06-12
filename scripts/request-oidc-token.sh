#!/usr/bin/env bash
set -euo pipefail

AUDIENCE="${1:-todo-registrar-statistic-action}"

if [[ -z "${ACTIONS_ID_TOKEN_REQUEST_URL:-}" || -z "${ACTIONS_ID_TOKEN_REQUEST_TOKEN:-}" ]]; then
  echo "::error::OIDC token is unavailable. Add 'id-token: write' to workflow permissions."
  exit 1
fi

curl -sSf \
  -H "Accept: application/json; charset=utf-8" \
  -H "Authorization: bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" \
  "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=${AUDIENCE}" \
  | jq -r '.value'
