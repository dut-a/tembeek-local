#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI required}"
README="${2:?README required}"

grep -Fq 'cmd_project_restart()' "$CLI"
grep -Fq 'cmd_project_autostart()' "$CLI"
grep -Fq 'project_autostart_keys()' "$CLI"
grep -Fq 'autostart: false' "$CLI"

HELP="$("$CLI" --help)"
grep -Fq 'project restart <key>' <<<"$HELP"
grep -Fq 'project autostart <key> <on|off>' <<<"$HELP"

grep -Fq 'Restart and autostart' "$README"
grep -Fq 'tembeek-local project restart mysite' "$README"
grep -Fq 'tembeek-local project autostart mysite on' "$README"

awk '/^cmd_up\(\)/,/^}/' "$CLI" | grep -Fq 'project_autostart_keys'
awk '/^cmd_down\(\)/,/^}/' "$CLI" | grep -Fq 'project_autostart_keys'

echo NODE_PROJECT_LIFECYCLE_191_OK
