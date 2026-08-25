#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI required}"
README="${2:?README required}"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

LIB="$TMP/lib.sh"
sed '/^main "\$@"$/d' "$CLI" > "$LIB"
source "$LIB"

CONFIG_DIR="$TMP/config"
CONFIG_FILE="$CONFIG_DIR/config"
DEV_ROOT="$TMP/default"
mkdir -p "$DEV_ROOT" "$TMP/a" "$TMP/b"

unset TEMBEEK_PROJECT_ROOTS PROJECT_ROOTS
load_machine_config

[[ "$(effective_project_roots_value)" == "$DEV_ROOT" ]]

cmd_project_roots_set "$TMP/a" "$TMP/b" >/dev/null
grep -Fq "PROJECT_ROOTS=$TMP/a:$TMP/b" "$CONFIG_FILE"
[[ "$(effective_project_roots_value)" == "$TMP/a:$TMP/b" ]]

unset PROJECT_ROOTS
load_machine_config
[[ "$(effective_project_roots_value)" == "$TMP/a:$TMP/b" ]]

TEMBEEK_PROJECT_ROOTS="$TMP/b"
[[ "$(effective_project_roots_value)" == "$TMP/b" ]]
[[ "$(project_roots_source)" == "environment override (TEMBEEK_PROJECT_ROOTS)" ]]

HELP="$("$CLI" --help)"
for cmd in \
  "tembeek-local project roots" \
  "tembeek-local project roots set" \
  "tembeek-local project roots add" \
  "tembeek-local project roots remove"; do
  grep -Fq "$cmd" <<<"$HELP"
  grep -Fq "$cmd" "$README"
done

echo PROJECT_ROOTS_CONFIG_182_OK
