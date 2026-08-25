#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI required}"
README="${2:?README required}"

HELP="$("$CLI" --help)"

required_commands=(
  "tembeek-local project discover"
  "tembeek-local project registry verify"
  "tembeek-local project registry rebuild"
  "tembeek-local project register"
  "tembeek-local project setup"
  "tembeek-local db create"
  "tembeek-local db migrate"
  "tembeek-local db status"
  "tembeek-local up"
  "tembeek-local down"
  "tembeek-local status"
)

for cmd in "${required_commands[@]}"; do
  grep -Fq "$cmd" <<<"$HELP"
  grep -Fq "$cmd" "$README"
done

grep -Fq "projects.json is a derived machine index" <<<"$HELP"
grep -Fq "projects.json" "$README"
grep -Fq "TEMBEEK_PROJECT_ROOTS" <<<"$HELP"
grep -Fq "TEMBEEK_PROJECT_ROOTS" "$README"

echo HELP_README_SYNC_181_OK
