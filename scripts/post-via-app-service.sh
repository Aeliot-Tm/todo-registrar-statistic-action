#!/usr/bin/env bash
set -euo pipefail

SERVICE_URL="${1:?posting service URL required}"
PR_NUMBER="${2:?PR number required}"
COMMENT_PATH="${3:?comment body path required}"
OIDC_AUDIENCE="${OIDC_AUDIENCE:-todo-registrar-statistic-action}"

if [[ ! -f "$COMMENT_PATH" ]]; then
  echo "::error::Comment body file not found: $COMMENT_PATH"
  exit 1
fi

if [[ -z "${GITHUB_REPOSITORY:-}" ]]; then
  echo "::error::GITHUB_REPOSITORY is not set"
  exit 1
fi

IS_FORK="$(jq -r '.pull_request.head.repo.fork // false' "${GITHUB_EVENT_PATH:-/dev/null}" 2>/dev/null || echo false)"
if [[ "$IS_FORK" == "true" ]]; then
  echo "::notice::Skipping PR comment for fork pull request."
  echo "comment_id=" >> "${GITHUB_OUTPUT:-/dev/null}"
  echo "comment_created=false" >> "${GITHUB_OUTPUT:-/dev/null}"
  exit 0
fi

if [[ -z "$SERVICE_URL" ]]; then
  echo "::error::posting_service_url is empty. Deploy the maintainer posting service or set post_as_app: false."
  exit 1
fi

OIDC_TOKEN="$("${BASH_SOURCE%/*}/request-oidc-token.sh" "$OIDC_AUDIENCE")"
REQUEST_BODY="$(jq -n \
  --arg repository "$GITHUB_REPOSITORY" \
  --argjson pr_number "$PR_NUMBER" \
  --arg comment_body "$(cat "$COMMENT_PATH")" \
  --arg oidc_token "$OIDC_TOKEN" \
  '{repository: $repository, pr_number: $pr_number, comment_body: $comment_body, oidc_token: $oidc_token}')"

RESPONSE_PATH="${RUNNER_TEMP:-/tmp}/todo-registrar-posting-response.json"
HTTP_CODE="$(curl -sS -o "$RESPONSE_PATH" -w "%{http_code}" -X POST "${SERVICE_URL%/}/v1/post-comment" \
  -H "Content-Type: application/json" \
  -d "$REQUEST_BODY")"

RESPONSE="$(cat "$RESPONSE_PATH")"
COMMENT_ID="$(echo "$RESPONSE" | jq -r '.comment_id // empty')"
COMMENT_CREATED="$(echo "$RESPONSE" | jq -r '.comment_created // false')"

if [[ "$HTTP_CODE" != "200" || -z "$COMMENT_ID" ]]; then
  ERROR_MESSAGE="$(echo "$RESPONSE" | jq -r '.error // empty')"
  if [[ -z "$ERROR_MESSAGE" ]]; then
    ERROR_MESSAGE="HTTP ${HTTP_CODE} from posting service"
  fi
  echo "::error::Posting service failed: ${ERROR_MESSAGE}"
  exit 1
fi

echo "comment_id=${COMMENT_ID}" >> "${GITHUB_OUTPUT}"
echo "comment_created=${COMMENT_CREATED}" >> "${GITHUB_OUTPUT}"
