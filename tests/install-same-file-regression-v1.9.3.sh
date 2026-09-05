#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI required}"
README="${2:?README required}"

grep -Fq '"$$source_file" -ef "$$dest_file"' Makefile
grep -Fq 'Canonical command already installed' Makefile
grep -Fq 'Idempotent reinstall' "$README"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/prefix/bin"
ln "$CLI" "$TMP/prefix/bin/tembeek-local"
PATH="/usr/bin:/bin:/usr/sbin:/sbin" make --no-print-directory install PREFIX="$TMP/prefix" >"$TMP/out" 2>"$TMP/err"
grep -Fq 'Canonical command already installed' "$TMP/out"
[[ -L "$TMP/prefix/bin/tl" ]]
[[ "$(readlink "$TMP/prefix/bin/tl")" == "tembeek-local" ]]
"$TMP/prefix/bin/tl" --version >/dev/null
echo INSTALL_SAME_FILE_193_OK
