#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI required}"

# The command dispatcher already shifts once before the case statement.
! grep -A4 -E '^[[:space:]]+up\)' "$CLI" | grep -q '^[[:space:]]+shift$'
! grep -A4 -E '^[[:space:]]+down\)' "$CLI" | grep -q '^[[:space:]]+shift$'
! grep -A4 -E '^[[:space:]]+status\)' "$CLI" | grep -q '^[[:space:]]+shift$'

# Lifecycle must use the real protocol-ready helper, not the removed/nonexistent name.
! grep -q 'mysql_native_runtime_running' "$CLI"
grep -q 'homebrew_mysql_protocol_ready' "$CLI"

echo LIFECYCLE_171_REGRESSION_OK
