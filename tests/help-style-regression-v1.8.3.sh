#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI required}"
README="${2:?README required}"

# Static style contract: usage must retain terminal style variables and styled sections.
grep -Fq 'local BOLD RESET DIM CYAN GREEN YELLOW' "$CLI"
grep -Fq '${BOLD}USAGE${RESET}' "$CLI"
grep -Fq '${BOLD}WORKSTATION SETUP${RESET}' "$CLI"
grep -Fq '${BOLD}PROJECTS${RESET}' "$CLI"
grep -Fq '${CYAN}project discover${RESET}' "$CLI"
grep -Fq '${CYAN}project roots${RESET}' "$CLI"
grep -Fq '${CYAN}project registry rebuild${RESET}' "$CLI"

HELP="$("$CLI" --help)"
for cmd in \
  "project roots" \
  "project discover" \
  "project registry verify" \
  "project registry rebuild"; do
  grep -Fq "$cmd" <<<"$HELP"
done

grep -Fq 'Built-in help' "$README"
echo HELP_STYLE_183_OK
