#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI required}"
README="${2:?README required}"

grep -Fq 'local BOLD RESET DIM CYAN GREEN YELLOW BLUE MAGENTA' "$CLI"
grep -Fq '${MAGENTA}New workstation${RESET}' "$CLI"
grep -Fq '${CYAN}tembeek-local project restart mysite${RESET}' "$CLI"
grep -Fq '${BLUE}Alias registry${RESET}' "$CLI"
grep -Fq '${GREEN}${LOCALHOST_ROOT}${RESET}' "$CLI"
grep -Fq '${CYAN}TEMBEEK_PROJECT_ROOTS${RESET}' "$CLI"
grep -Fq '${YELLOW}↓${RESET}' "$CLI"
grep -Fq '${MAGENTA}Installed commands${RESET}' "$CLI"
grep -Fq '${GREEN}tembeek-local${RESET}   ${DIM}Canonical command${RESET}' "$CLI"
grep -Fq '${GREEN}tl${RESET}              ${DIM}Short executable alias for tembeek-local${RESET}' "$CLI"

HELP="$("$CLI" --help)"
if printf '%s' "$HELP" | LC_ALL=C grep -q $'\033'; then
  echo "ANSI escape leaked in non-TTY help" >&2
  exit 1
fi

grep -Fq 'Installed commands' <<<"$HELP"
grep -Fq 'Canonical command' <<<"$HELP"
grep -Fq 'Short executable alias for tembeek-local' <<<"$HELP"
grep -Fq 'Help presentation' "$README"

echo HELP_COLOR_194_OK
