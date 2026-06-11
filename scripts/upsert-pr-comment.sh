#!/usr/bin/env bash
set -euo pipefail

PR_NUMBER="${1:?PR number required}"
COMMENT_PATH="${2:?comment body path required}"
MARKER="TODO-REGISTRAR-STATISTIC:START"

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
  echo "::notice::Skipping PR comment for fork pull request (token cannot comment on upstream PR)."
  echo "comment_id=" >> "$GITHUB_OUTPUT"
  echo "comment_created=false" >> "$GITHUB_OUTPUT"
  exit 0
fi

COMMENT_BODY="$(cat "$COMMENT_PATH")"

MATCHING_IDS="$(gh api --paginate \
  "repos/${GITHUB_REPOSITORY}/issues/${PR_NUMBER}/comments" \
  --jq ".[] | select(.body | contains(\"${MARKER}\")) | .id" || true)"

COMMENT_ID=""
MATCH_COUNT=0
while IFS= read -r id; do
  [[ -z "$id" ]] && continue
  MATCH_COUNT=$((MATCH_COUNT + 1))
  [[ -z "$COMMENT_ID" ]] && COMMENT_ID="$id"
done <<< "$MATCHING_IDS"

if [[ "$MATCH_COUNT" -gt 1 ]]; then
  echo "::warning::Found ${MATCH_COUNT} comments with marker ${MARKER}; updating the first match (id=${COMMENT_ID})."
fi

if [[ -n "$COMMENT_ID" ]]; then
  gh api \
    --method PATCH \
    -H "Accept: application/vnd.github+json" \
    "repos/${GITHUB_REPOSITORY}/issues/comments/${COMMENT_ID}" \
    -f body="$COMMENT_BODY" > /dev/null
  echo "comment_created=false" >> "${GITHUB_OUTPUT}"
else
  RESPONSE="$(gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    "repos/${GITHUB_REPOSITORY}/issues/${PR_NUMBER}/comments" \
    -f body="$COMMENT_BODY")"
  COMMENT_ID="$(echo "$RESPONSE" | jq -r '.id')"
  echo "comment_created=true" >> "${GITHUB_OUTPUT}"
fi

echo "comment_id=${COMMENT_ID}" >> "${GITHUB_OUTPUT}"
