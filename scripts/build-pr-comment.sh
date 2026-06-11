#!/usr/bin/env bash
set -euo pipefail

REPORT_PATH="${1:?report path required}"
COMMENT_PATH="${2:?comment output path required}"
LOGO_URL="https://raw.githubusercontent.com/Aeliot-Tm/todo-registrar-statistic-action/main/docs/logo.svg"
ACTION_LINK="[TODO Registrar Statistic Action](https://github.com/Aeliot-Tm/todo-registrar-statistic-action)"
MARKER_START="<!-- TODO-REGISTRAR-STATISTIC:START -->"
MARKER_END="<!-- TODO-REGISTRAR-STATISTIC:END -->"

pluralize() {
  local count="$1"
  local singular="$2"
  local plural="$3"

  if [[ "$count" == "1" ]]; then
    echo "$singular"
  else
    echo "$plural"
  fi
}

write_alert() {
  local registered="$1"
  local analyzed="$2"

  if [[ "$registered" -eq 0 ]]; then
    echo "> [!TIP]"
    if [[ -n "$analyzed" ]]; then
      echo "> No unregistered TODOs found. Scanned **${analyzed}** $(pluralize "$analyzed" "file" "files")."
    else
      echo "> No unregistered TODOs found."
    fi
  else
    echo "> [!NOTE]"
    echo "> Currently **${registered}** unregistered $(pluralize "$registered" "TODO" "TODOs") in the scanned codebase."
    echo "> This reflects the current state of the PR branch, not only TODOs added in this pull request."
    echo "> Report by ${ACTION_LINK}."
  fi
}

write_footer() {
  local server_url="${GITHUB_SERVER_URL:-https://github.com}"
  local repository="${GITHUB_REPOSITORY:-}"
  local run_id="${GITHUB_RUN_ID:-}"
  local commit_sha="${COMMIT_SHA:-}"

  [[ -n "$run_id" && -n "$repository" ]] || return 0

  local workflow_url="${server_url}/${repository}/actions/runs/${run_id}"
  local footer="> Run by [workflow #${run_id}](${workflow_url})"

  if [[ -n "$commit_sha" ]]; then
    footer+=" · [view commit](${server_url}/${repository}/commit/${commit_sha})"
  fi

  echo ""
  echo "$footer"
}

{
  echo "$MARKER_START"
  echo ""
  echo '<div align="center">'
  echo ""
  echo "![TODO Registrar](${LOGO_URL})"
  echo ""
  echo '</div>'
  echo ""

  if [[ -f "$REPORT_PATH" ]]; then
    read -r REGISTERED NEW_ISSUES GLUED <<< "$(jq -r '.summary.todos | "\(.registered) \(.newIssues) \(.glued)"' "$REPORT_PATH")"
    ANALYZED="$(jq -r '.summary.files.analyzed // empty' "$REPORT_PATH")"
    UNREGISTERED_FILES="$(jq '[.files[]? | select(.summary.todos.registered > 0)] | length' "$REPORT_PATH")"

    write_alert "$REGISTERED" "$ANALYZED"

    if [[ "$REGISTERED" -gt 0 ]]; then
      echo ""
      echo "---"
      echo ""
      echo "## Unregistered TODO summary"
      echo ""

      echo "| Unregistered | New issues | Glued |"
      echo "| :----------: | :--------: | :---: |"
      echo "| **${REGISTERED}** | **${NEW_ISSUES}** | **${GLUED}** |"
      echo ""
      echo "- **Unregistered** — TODO comments without an issue key that would be registered"
      echo "- **New issues** — new tracker tickets that would be created (\`registered - glued\`)"
      echo "- **Glued** — TODOs that would reuse an existing issue key"
    fi

    if [[ "$UNREGISTERED_FILES" -gt 0 ]]; then
      echo ""
      echo "<details>"
      echo "<summary><strong>Files with unregistered TODOs</strong> (${UNREGISTERED_FILES})</summary>"
      echo ""
      echo "| File | Unregistered TODOs |"
      echo "|------|-------------------:|"
      jq -r '.files | map(select(.summary.todos.registered > 0)) | sort_by(-.summary.todos.registered) | .[] | "| `\(.path)` | \(.summary.todos.registered) |"' "$REPORT_PATH"
      echo ""
      echo "</details>"
    fi

    write_footer
    echo ""
    echo "$MARKER_END"
  else
    echo "> [!WARNING]"
    echo "> Processing report is not available."
    write_footer
    echo ""
    echo "$MARKER_END"
  fi
} > "$COMMENT_PATH"
